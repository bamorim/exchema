defmodule Exchema.Types.Float do
  @moduledoc "Represents a float"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :float}]}
  end
end
