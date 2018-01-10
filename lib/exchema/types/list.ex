defmodule Exchema.Types.List do
  alias Exchema.Predicates.List

  def __type__({type} \\ {:any}) do
    {:ref, :any, [{List, element_type: type}]}
  end
end
