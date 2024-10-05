defmodule Canary.Index.Collection do
  def ensure(name) when name in [:webpage, :openapi, :github_issue, :github_discussion] do
    with {:error, _} <- Canary.Index.Client.get_collection(name),
         {:error, _} <- Canary.Index.Client.create_collection(name, fields(name)) do
      :error
    else
      _ -> :ok
    end
  end

  defp fields(name) when name in [:webpage, :openapi, :github_issue, :github_discussion] do
    # https://typesense.org/docs/27.0/api/collections.html#indexing-all-but-some-fields
    shared = [
      %{name: "source_id", type: "string"},
      %{name: "embedding", type: "float[]", num_dim: 384, optional: true},
      %{name: "tags", type: "string[]"},
      %{name: "is_empty_tags", type: "bool"},
      %{name: "meta", type: "object", index: false, optional: true}
    ]

    specific =
      case name do
        :webpage ->
          [
            %{name: "title", type: "string", stem: true},
            %{name: "content", type: "string", stem: true}
          ]

        :openapi ->
          [
            %{name: "path", type: "string", stem: true},
            %{name: "get", type: "string", stem: true, optional: true},
            %{name: "post", type: "string", stem: true, optional: true},
            %{name: "put", type: "string", stem: true, optional: true},
            %{name: "delete", type: "string", stem: true, optional: true}
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
