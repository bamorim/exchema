defmodule Exchema.Coercions.Integer do
  @moduledoc false
  def coerce(float) when is_float(float), do: round(float)
  def coerce(str) when is_binary(str) do
    case Integer.parse(str) do
      {new, _} -> new
      :error -> str
    end
  end
  def coerce(v), do: v
end
