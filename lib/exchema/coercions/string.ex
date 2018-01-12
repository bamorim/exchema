defmodule Exchema.Coercions.String do
  @moduledoc false
  def coerce(input), do: to_string(input)
end
