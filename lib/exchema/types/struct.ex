defmodule Exchema.Types.Struct do
  alias Exchema.{
    Types,
    Predicates
  }
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
