defmodule Canary.Sessions.Message do
  defstruct [:role, :content]

  def user(content), do: %__MODULE__{role: :user, content: content}
  def assistant(content), do: %__MODULE__{role: :assistant, content: content}
end
