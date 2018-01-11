defmodule Exchema.Types.DateTime do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, DateTime}]}
  end
end
