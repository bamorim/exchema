defmodule Exchema.Types.Tuple do
  @moduledoc "Represents a tuple of any size"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :tuple}]}
  end
end
