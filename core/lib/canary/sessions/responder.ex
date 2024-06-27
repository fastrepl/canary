defmodule Canary.Sessions.Responder do
  @type args :: %{
          history: list(),
          source_ids: list(),
          handle_message: function(),
          handle_message_delta: function()
        }

  @callback call(args()) :: any()

  def call(args), do: impl().call(args)
  defp impl, do: Application.get_env(:canary, :session_responder, Canary.Sessions.Responder.LLM)
end

defmodule Canary.Sessions.Responder.LLM do
  @behaviour Canary.Sessions.Responder
  require Ash.Query

  def call(%{
        history: history,
        source_ids: source_ids,
        handle_message: handle_message,
        handle_message_delta: _handle_message_delta
      }) do
    model = Application.fetch_env!(:canary, :chat_completion_model)

    user_query = history |> Enum.at(-1) |> Map.get(:content)
    {:ok, queries} = Canary.Query.Understander.run(user_query)

    docs =
      queries
      |> Enum.map(fn query ->
        Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
          Canary.Sources.Document
          |> Ash.Query.filter(source_id in ^source_ids)
          |> Ash.Query.for_read(:hybrid_search, %{text: query.text, embedding: query.embedding})
          |> Ash.Query.limit(6)
          |> Ash.read!()
        end)
      end)
      |> Task.await_many(5000)
      |> Enum.flat_map(fn docs -> docs end)
      |> Enum.uniq_by(& &1.id)

    {:ok, docs} = Canary.Reranker.run(user_query, docs)

    messages = [
      %{
        role: "user",
        content: """
        #{render_context(docs)}

        #{render_history(history)}

        <user_question>
        #{user_query}
        </user_question>

        Based on the retrieved documents, answer the user's question within 5 sentences. KEEP IT SIMPLE AND CONCISE.
        If user is asking for nonsense, or the retrieved documents are not relevant, just transparently say it.
        """
      }
    ]

    {:ok, res} =
      Canary.AI.chat(%{model: model, messages: messages, stream: false, max_tokens: 300})

    result = if docs != [], do: "#{res}\n\n#{render_sources(docs)}", else: res
    handle_message.(result)
  end

  defp render_history(history) do
    if history != [] do
      body =
        history
        |> Enum.map(&Canary.Renderable.render/1)
        |> Enum.join("\n\n")

      "<history>\n#{body}\n</history>"
    else
      ""
    end
  end

  defp render_context(docs) do
    if docs != [] do
      body =
        docs
        |> Enum.map(&Canary.Renderable.render/1)
        |> Enum.join("\n\n")

      "<retrieved_documents>\n#{body}\n</retrieved_documents>"
    else
      "<retrieved_documents>\nNo relevant documents found.\n</retrieved_documents>"
    end
  end

  defp render_sources(docs) do
    docs
    |> Enum.map(& &1.source_url)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.map(fn url -> "- <#{url}>" end)
    |> Enum.join("\n")
  end
end
