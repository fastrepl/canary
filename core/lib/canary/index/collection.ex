defmodule Canary.Index.Collection do
  def ensure(name) when name in [:webpage, :github_issue, :github_discussion] do
    with {:error, _} <- Canary.Index.Client.get_collection(name),
         {:error, _} <- Canary.Index.Client.create_collection(name, fields(name)) do
      :error
    else
      _ -> :ok
    end
  end

  defp fields(name) when name in [:webpage, :github_issue, :github_discussion] do
    shared = [
      %{name: "source_id", type: "string"},
      %{name: "embedding", type: "float[]", num_dim: 384, optional: true},
      %{name: "tags", type: "string[]"},
      %{name: "meta", type: "object", index: false, optional: true}
    ]

    specific =
      case name do
        :webpage ->
          [
            %{name: "title", type: "string", stem: true},
            %{name: "content", type: "string", stem: true}
          ]

        :github_issue ->
          [
            %{name: "title", type: "string", stem: true},
            %{name: "content", type: "string", stem: true}
          ]

        :github_discussion ->
          [
            %{name: "title", type: "string", stem: true},
            %{name: "content", type: "string", stem: true}
          ]
      end

    specific ++ shared
  end
end
