defmodule Exchema.Types.String do
  @moduledoc "Represents any string/binary"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :binary}]}
  end
end
