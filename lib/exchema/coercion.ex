defmodule Exchema.Coercion do
  @moduledoc """
  Automagically coercion for Exchema Types

  This will probable be extracted into its own library later.
  """

  alias Exchema.Coercions, as: C
  alias Exchema.Types, as: T
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
  def coerce(input, {:ref, supertype, refinements}) do
    cond do
      is_struct(refinements) ->
        coerce_struct(input, refinements)

      true ->
        coerce(input, supertype)
    end
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

  defp coerce_struct(%{} = input, refinements) do
    struct_mod = Keyword.get(refinements, :is_struct)

    struct_mod
    |> struct
    |> Map.keys
    |> Enum.filter(&(&1 != :__struct__))
    |> Enum.reduce(struct(struct_mod),
      fn (key, output) ->
        Map.put(output, key, fuzzy_get(input, key))
      end
    )
    |> coerce_map_values(refinements)
  end

  defp coerce_map_values(map, refinements) do
    map_fields =
      refinements
      |> Keyword.get(:map, [])
      |> Keyword.get(:fields)

    if map_fields do
      map_fields
      |> Enum.reduce(map,
        fn({key, type}, map) ->
          Map.put(map, key, coerce(Map.get(map, key), type))
        end
      )
    else
      map
    end
  end

  defp is_struct(refinements) do
    Keyword.has_key? refinements, :is_struct
  end

  defp fuzzy_get(map, key) do
    [&(&1), &to_string/1]
    |> Enum.map(&(Map.get(map, &1.(key))))
    |> Enum.filter(&(&1))
    |> List.first
  end
end
