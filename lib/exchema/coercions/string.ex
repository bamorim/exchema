defmodule Exchema.Coercions.String do
  def coerce(input), do: to_string(input)
end
