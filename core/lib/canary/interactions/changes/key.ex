defmodule Canary.Interactions.Changes.Key do
  use Ash.Resource.Change

  @chars Enum.to_list(?A..?Z) ++ Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)

  @impl true
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.force_change_attribute(opts[:attribute], opts[:prefix] <> random())
  end

  defp random() do
    1..24
    |> Enum.map(fn _ -> Enum.random(@chars) end)
    |> List.to_string()
  end
end
