defmodule Exchema.Types.Tuple do
  @moduledoc "Represents a tuple of any size"
  alias Exchema.Predicates

  @type t :: tuple()

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :tuple}]}
  end
end
