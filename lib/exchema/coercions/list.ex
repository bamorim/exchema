defmodule Exchema.Coercions.List do
  @moduledoc false

  def coerce(input, {}), do: coerce(input, :any)
  def coerce(input, inner_type) when is_list(input) do
    input
    |> Enum.map(&(Exchema.Coercion.coerce(&1, inner_type)))
  end

  def coerce(input, inner_type) when is_tuple(input) do
    input
    |> Tuple.to_list
    |> coerce(inner_type)
  end

  def coerce(i, _), do: i
end
