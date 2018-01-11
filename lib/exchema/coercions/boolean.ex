defmodule Exchema.Coercions.Boolean do
  def coerce("true"), do: true
  def coerce("false"), do: false
  def coerce(v), do: v
end
