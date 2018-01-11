defmodule Exchema.Struct do
  defmacro __using__(opts \\ []) do
    fields = Keyword.get(opts, :fields, [])
    struct_fields = fields |> Enum.map(fn {k, _} -> {k, nil} end)

    quote do
      defstruct unquote(struct_fields)

      def __type__({}) do
        {:ref, :any,
         is_struct: __MODULE__,
         map: [
           fields: unquote(fields)
         ]
        }
      end
    end
  end
end
