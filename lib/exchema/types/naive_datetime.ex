defmodule Exchema.Types.NaiveDateTime do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, NaiveDateTime}]}
  end
end
