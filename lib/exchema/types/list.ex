defmodule Exchema.Types.List do
  alias Exchema.Predicates

  def __type__({}), do: __type__({:any})
  def __type__({type}) do
    {:ref, :any, [{{Predicates, :list}, element_type: type}]}
  end
end
