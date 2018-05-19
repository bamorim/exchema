defmodule Exchema.Types.List do
  @moduledoc """
  Represent a List and its element types.

  If you want a list of integers, then you want to
  use `{Exchema.Types.List, Exchema.Types.Integer}`
  as your type.

  If you don't care about list element types, it will
  default to `:any`, so `Exchema.Types.List` is the same
  as `{Exchema.Types.List, :any}`.
  """
  alias Exchema.Predicates

  @doc false
  def __type__({}), do: __type__({:any})
  def __type__({type}) do
    {:ref, :any, [{{Predicates, :list}, type}]}
  end
end
