defmodule Exchema.Coercion do
  @moduledoc """
  Automagically coercion for Exchema Types

  This will probable be extracted into its own library later.
  """

  alias Exchema.Type

  # Match on some concrete types
  def coerce(input, :any), do: input
  # Simple Type
  def coerce(input, type) when is_atom(type), do: coerce(input, {type, {}})
  # Parametric Types
  def coerce(input, {_, _} = type) do
    get_coercion_fun(type).(input)
  end
  # Refined Type
  def coerce(input, {:ref, supertype, _}) do
    coerce(input, supertype)
  end

  defp get_coercion_fun({type_mod, type_args} = type) do
    cond do
      Exchema.Coercions.coerces?(type) ->
        &(Exchema.Coercions.coerce(&1, type))
      :erlang.function_exported(type_mod, :__coerce__, 2) ->
        &(type_mod.__coerce__(&1, type_args))
      :erlang.function_exported(type_mod, :__coerce__, 1) ->
        &type_mod.__coerce__/1
      true ->
        &(coerce(&1, Type.resolve_type(type)))
    end
  end
end
