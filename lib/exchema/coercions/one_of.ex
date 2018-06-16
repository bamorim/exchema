defmodule Exchema.Coercions.OneOf do
  @moduledoc false

  def coerce(input, types) do
    types
    |> Stream.map(& {&1, Exchema.Coercion.coerce(input, &1)})
    |> Stream.filter(fn {t, v} -> Exchema.is?(v, t) end)
    |> Enum.at(0)
    |> case do
      nil ->
        input
      {_, value} ->
        value
      end
  end
end