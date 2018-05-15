defmodule Exchema.Notation.Struct do
  def __struct(fields) do
    quote do
      @super_type {Exchema.Types.Struct, {__MODULE__, unquote(fields)}}
      defstruct unquote(__field_keys(fields))
      @refinements []
      @before_compile Exchema.Notation.Subtype
    end
  end

  defp __field_keys(fields) do
    fields
    |> Enum.map(fn {k,_} -> k end)
  end
end
