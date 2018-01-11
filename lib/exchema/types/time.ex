defmodule Exchema.Types.Time do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, Time}]}
  end
end
