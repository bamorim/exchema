defmodule Exchema.Types.Struct do
  @moduledoc """
  Represents a specific struct with some field constraints.

  Normally you won't use this type directly but will instead
  define your struct using `Exchema.Struct`.

  Say that you have a struct `Data` with a field `value`.

  If you want to make sure the value is an integer, you can
  represent it with

      {Exchema.Types.Struct,
        {Data, [
          value: Exchema.Types.Integer
        ]}
      }

  If you don't care about the field values, you can represent it
  with {Exchema.Types.Struct, Data}.
  """

  alias Exchema.{
    Types,
    Predicates
  }

  @doc false
  def __type__({}), do: __type__({:any, []})
  def __type__({mod}), do: __type__({mod, []})
  def __type__({mod, fields}) do
    {
      :ref,
      {Types.Map, {Types.Atom, :any}},
      [
        {{Predicates, :is_struct}, mod},
        {{Predicates, :map}, fields: fields}
      ]
    }
  end
end
