defmodule Exchema.Types.Atom do
  @moduledoc "Represents an atom"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :atom}]}
  end
end
