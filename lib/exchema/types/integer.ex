defmodule Exchema.Types.Integer do
  alias Exchema.Predicates.Fun

  def __type__({}) do
    {:ref, :any, [{Fun, &is_integer/1}]}
  end
end
