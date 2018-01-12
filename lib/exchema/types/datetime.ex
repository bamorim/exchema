defmodule Exchema.Types.DateTime do
  @moduledoc "Represents DateTime struct"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, DateTime}]}
  end
end
