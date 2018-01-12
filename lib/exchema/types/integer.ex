defmodule Exchema.Types.Integer do
  @moduledoc "Represents an integer"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :integer}]}
  end
end
