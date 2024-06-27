defprotocol Canary.Renderable do
  @spec render(t) :: String.t()
  def render(t)
end

defimpl Canary.Renderable, for: Canary.Sources.Document do
  def render(doc) do
    """
    ```#{doc.source_url}
    #{doc.content}
    ```
    """
  end
end
