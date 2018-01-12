defmodule Exchema.Types.Number do
  @moduledoc "Represents a number, either a float or an integer"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :number}]}
  end
end
