defmodule Exchema.Notation.Type do
  @moduledoc false
  def __type(refinements) do
    Exchema.Notation.Subtype.__subtype(:any, refinements)
  end
end
