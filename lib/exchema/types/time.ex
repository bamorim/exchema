defmodule Exchema.Types.Time do
  @moduledoc "Represents Time struct"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, Time}]}
  end
end
