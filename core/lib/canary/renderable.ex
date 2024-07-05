defprotocol Canary.Renderable do
  @fallback_to_any true

  @spec render(t) :: String.t()
  def render(t)
end

defimpl Canary.Renderable, for: Any do
  def render(value), do: to_string(value)
end

defimpl Canary.Renderable, for: Canary.Interactions.Message do
  def render(%{role: :user, content: content}), do: "<user>\n#{content}\n</user>"
  def render(%{role: :assistant, content: content}), do: "<canary>\n#{content}\n</canary>"
end
