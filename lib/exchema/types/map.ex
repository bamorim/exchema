defmodule Exchema.Types.Map do
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
