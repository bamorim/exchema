defmodule Exchema.Types.Integer do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :integer}]}
  end
end
