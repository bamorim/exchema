defmodule Exchema.Types.Float do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :float}]}
  end
end
