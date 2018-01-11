defmodule Exchema.Types.Date do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, Date}]}
  end
end
