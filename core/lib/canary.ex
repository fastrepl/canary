defmodule Canary do
  def rest_client(opts \\ []) do
    Req.new(opts)
  end
end
