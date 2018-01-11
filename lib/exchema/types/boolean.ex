defmodule Exchema.Types.Boolean do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :boolean}]}
  end
end
