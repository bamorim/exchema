defmodule Exchema.Types.Map do
  @moduledoc """
  Represents a Map with given key and value types.

  If you want a map of integers to atoms, then you want to
  use `{Exchema.Types.Map, {Exchema.Types.Integer, Exchema.Types.Atom}}`
  as your type.

  If you don't care about map key and value types, it will
  default to `:any`, so `Exchema.Types.Map` is the same
  as `{Exchema.Types.Map, {:any, :any}}`.
  """

  @doc false
  def __type__({}), do: __type__({:any, :any})
  def __type__({key_type, value_type}) do
    {
      :ref,
      :any,
      [
        {{Exchema.Predicates, :map}, [
          keys: key_type,
          values: value_type
        ]}
      ]
    }
  end
end
