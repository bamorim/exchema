defmodule Exchema.Types.Atom do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :atom}]}
  end
end
