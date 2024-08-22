defmodule Canary.Interactions.Responder do
  alias Canary.Interactions.Responder

  @callback run(
              session :: any(),
              query :: String.t(),
              pattern :: String.t() | nil,
              client :: any(),
              handle_delta :: function()
            ) :: {:ok, any()} | {:error, any()}

  def run(session, query, pattern, client, handle_delta \\ nil) do
    impl().run(session, query, pattern, client, handle_delta)
  end

  defp impl, do: Application.get_env(:canary, :responder, Responder.Default)
end

defmodule Canary.Interactions.Responder.Default do
  @behaviour Canary.Interactions.Responder
  require Ash.Query

  alias Canary.Interactions.Client

  def run(session, query, pattern, %Client{account: account, sources: sources}, handle_delta) do
    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Interactions.Message.add_user!(session, query)
    end)

    model = Application.fetch_env!(:canary, :chat_completion_model_response)
    source = sources |> Enum.at(0)
    {:ok, %{search: docs}} = Canary.Searcher.run(source, query)

    docs =
      if is_nil(pattern) do
        docs
      else
        docs
        |> Enum.filter(fn doc -> Canary.Native.glob_match(pattern, URI.parse(doc.url).path) end)
      end

    messages = [
      %{
        role: "system",
        content: """
        You are a world class techincal support engineer.
        I will provide user's question and retrieved relevant documents, and you should answer it. Detailed guideline will be also provided.

        In any case, you must respond in markdown format. Header, Link, Inline Code, Block Code, Bold, Italic and Footnotes are supported.

        Notes about tags:

        - Header:
        If the response is simple, you don't need to use header. But for most case, it is essential to use headers to structure the response.
        Be careful not to make the response too long or over-complicated.

        - Bold:
        This can boost the readability. Use it for important points, or sentence that actually answer the user's question.

        - Inline Code:
        Also for readability gain. Should be used for domain-specific terms, pronouns, and code-related things.

        - Code Block:
        Always add language tag after the triple backticks. For example:

        ```markup
        <div class="container">
          <h1>Hello World</h1>
        </div>
        ```

        - Footnotes:
        Use it to reference the related document with the sentence, like this[^1]. (no duplicate footnotes)
        Only single number footnote is allowed, no range, no multiple numbers.
        At the end of the response, include the footnotes which strictly follow the format below:

        [^1]: 2
        [^2]: 6
        [^3]: 4

        This means the first footnote is referencing the document at index 2, the second is referencing the document at index 6, and so on.
        When writing footnotes, do not add heading or other formatting around <notes> tag.

        You should add enough footnotes as possible for transparency and accuracy. At least one footnote is required.
        """
      },
      %{
        role: "user",
        content: """
        #{render_context(docs)}

        #{render_history(session.messages)}

        <user_question>
        #{query}
        </user_question>

        <instruction>
        Based on the retrieved documents, answer the user's question within 5 sentences. Note that user's question might contains some typos.
        Go straight to the point, give answer first, then go through the details. Each sentence should be short, and paragraph should only contain few sentences.

        If user is asking for nonsense, or the retrieved documents are not relevant, just transparently say it.

        Don't forget to include footnotes like below:
        ```
        [^1]: 2
        [^2]: 6
        [^3]: 4
        ```
        </instruction>
        """
      }
    ]

    {:ok, pid} = Agent.start_link(fn -> "" end)

    {:ok, completion} =
      Canary.AI.chat(
        %{
          model: model,
          messages: messages,
          temperature: 0.2,
          frequency_penalty: 0.02,
          max_tokens: 5000,
          stream: handle_delta != nil
        },
        callback: fn data ->
          case data do
            %{"choices" => [%{"finish_reason" => reason}]}
            when reason in ["stop", "length", "eos"] ->
              :ok

            %{"choices" => [%{"delta" => %{"content" => content}}]} ->
              safe(handle_delta, %{type: :progress, content: content})
              Agent.update(pid, &(&1 <> content))
          end
        end
      )

    completion = if completion == "", do: Agent.get(pid, & &1), else: completion

    references =
      completion
      |> parse_footnotes()
      |> Enum.map(fn i -> Enum.at(docs, i - 1) end)

    safe(handle_delta, %{type: :references, items: references})
    safe(handle_delta, %{type: :complete, content: completion})

    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Accounts.Billing.increment_ask(account.billing)
      Canary.Interactions.Message.add_assistant!(session, completion)
    end)

    {:ok, %{response: completion, references: references}}
  end

  defp render_history(history) do
    if history != [] do
      body =
        history
        |> Enum.sort_by(& &1.created_at, &(DateTime.compare(&1, &2) == :lt))
        |> Enum.map(&Canary.Renderable.render/1)
        |> Enum.join("\n\n")

      "<history>\n#{body}\n</history>"
    else
      ""
    end
  end

  defp render_context(docs) do
    if length(docs) > 0 do
      body =
        docs
        |> Enum.with_index(1)
        |> Enum.map(fn {%{title: title, content: content}, index} ->
          "index: #{index}\n\ntitle: #{title}\n\ncontent: #{content}\n"
        end)
        |> Enum.join("\n-------\n")

      "<retrieved_documents>\n#{body}\n</retrieved_documents>"
    else
      "<retrieved_documents>\nNo relevant documents found.\n</retrieved_documents>"
    end
  end

  defp safe(func, arg) do
    if is_function(func, 1), do: func.(arg), else: :noop
  end

  def parse_footnotes(text) do
    regex = ~r/\[\^(\d+)\]:\s*(\d+)\s*$/m

    Regex.scan(regex, text)
    |> Enum.sort_by(fn [_, footnote_number, _] ->
      String.to_integer(footnote_number)
    end)
    |> Enum.map(fn [_, _, index] ->
      String.to_integer(index)
    end)
  end
end
