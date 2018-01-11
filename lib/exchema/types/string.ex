defmodule Exchema.Types.String do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is}, :binary}]}
  end
end
