defmodule Exchema.Types.Boolean do
  @moduledoc "Represents a boolean"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :boolean}]}
  end
end
