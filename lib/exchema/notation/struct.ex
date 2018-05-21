defmodule Exchema.Notation.Struct do
  @moduledoc false
  def __struct(fields) do
    quote do
      defstruct unquote(__field_keys(fields))
      Exchema.Notation.subtype({Exchema.Types.Struct, {__MODULE__, unquote(fields)}}, [])
    end
  end

  defp __field_keys(fields) do
    fields
    |> Enum.map(fn {k,_} -> k end)
  end
end
