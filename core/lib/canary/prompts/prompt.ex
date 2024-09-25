defmodule Canary.Prompt do
  @understander_system_prompt_path Path.join(__DIR__, "understander_system.eex")
  @understander_user_prompt_path Path.join(__DIR__, "understander_user.eex")

  @responder_system_prompt_path Path.join(__DIR__, "responder_system.eex")
  @responder_user_prompt_path Path.join(__DIR__, "responder_user.eex")
  @responser_schema_path Path.join(__DIR__, "responder_assistant_schema.json")

  @external_resource @understander_system_prompt_path
  @external_resource @understander_user_prompt_path
  @external_resource @responder_system_prompt_path
  @external_resource @responder_user_prompt_path
  @external_resource @responser_schema_path

  @understander_system_prompt File.read!(@understander_system_prompt_path)
  @understander_user_prompt File.read!(@understander_user_prompt_path)

  @responder_system_prompt File.read!(@responder_system_prompt_path)
  @responder_user_prompt File.read!(@responder_user_prompt_path)
  @responser_schema File.read!(@responser_schema_path)

  def format("responder_system", inputs) do
    inputs
    |> Map.put(:schema, @responser_schema)
    |> then(&EEx.eval_string(@responder_system_prompt, assigns: &1))
    |> String.trim()
  end

  def format("responder_user", %{query: _, docs: _} = inputs) do
    inputs
    |> Map.put(:schema, @responser_schema)
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
