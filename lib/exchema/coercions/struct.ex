defmodule Exchema.Coercions.Struct do
  def coerce(input, struct_mod, fields) do
    struct_mod
    |> struct
    |> Map.keys
    |> Enum.filter(&(&1 != :__struct__))
    |> Enum.reduce(struct(struct_mod),
    fn (key, output) ->
      Map.put(output, key, fuzzy_get(input, key))
    end
    )
    |> coerce_values(fields)
  end

  defp coerce_values(map, fields) do
    fields
    |> Enum.reduce(map,
      fn({key, type}, map) ->
        Map.put(map, key, Exchema.Coercion.coerce(Map.get(map, key), type))
      end
    )
  end

  defp fuzzy_get(map, key) do
    [&(&1), &to_string/1]
    |> Enum.map(&(Map.get(map, &1.(key))))
    |> Enum.filter(&(&1))
    |> List.first
  end
end
