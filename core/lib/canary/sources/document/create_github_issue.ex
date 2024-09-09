defmodule Canary.Sources.Document.CreateGithubIssue do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if [
         :source_id_argument,
         :url_argument,
         :html_argument,
         :meta_attribute,
         :chunks_attribute
       ]
       |> Enum.any?(&is_nil(opts[&1])) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, _opts, _context) do
    changeset
  end
end
