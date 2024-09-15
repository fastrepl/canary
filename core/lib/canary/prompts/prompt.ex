defmodule Canary.Prompt do
  @responder_system_prompt_path Path.join(__DIR__, "responder_system.eex")
  @responder_user_prompt_path Path.join(__DIR__, "responder_user.eex")
  @understander_system_prompt_path Path.join(__DIR__, "understander_system.eex")
  @understander_user_prompt_path Path.join(__DIR__, "understander_user.eex")

  @external_resource @responder_system_prompt_path
  @external_resource @responder_user_prompt_path
  @external_resource @understander_system_prompt_path
  @external_resource @understander_user_prompt_path

  @responder_system_prompt File.read!(@responder_system_prompt_path)
  @responder_user_prompt File.read!(@responder_user_prompt_path)
  @understander_system_prompt File.read!(@understander_system_prompt_path)
  @understander_user_prompt File.read!(@understander_user_prompt_path)

  def format("responder_system", inputs) do
    inputs
    |> then(&EEx.eval_string(@responder_system_prompt, assigns: &1))
    |> String.trim()
  end

  def format("responder_user", %{query: _, docs: _} = inputs) do
    inputs
    |> then(&EEx.eval_string(@responder_user_prompt, assigns: &1))
    |> String.trim()
  end

  def format("understander_system", inputs) do
    inputs
    |> then(&EEx.eval_string(@understander_system_prompt, assigns: &1))
    |> String.trim()
  end

  def format("understander_user", %{query: _, keywords: _} = inputs) do
    inputs
    |> then(&EEx.eval_string(@understander_user_prompt, assigns: &1))
    |> String.trim()
  end
end
