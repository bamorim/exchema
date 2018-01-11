defmodule Exchema.Types.Tuple do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :tuple}]}
  end
end
