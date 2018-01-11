defmodule Exchema.Coercions.Float do
  def coerce(integer) when is_integer(integer), do: integer * 1.0
  def coerce(str) when is_binary(str) do
    case Float.parse(str) do
      {new, _} -> new
      :error -> str
    end
  end
  def coerce(v), do: v
end
