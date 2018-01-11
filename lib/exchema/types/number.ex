defmodule Exchema.Types.Number do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :number}]}
  end
end
