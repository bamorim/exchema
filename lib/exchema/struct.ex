defmodule Exchema.Struct do
  defmacro __using__(opts \\ []) do
    fields = Keyword.get(opts, :fields, [])
    struct_fields = fields |> Enum.map(fn {k, _} -> {k, nil} end)
    schema_predicates = Keyword.get(opts, :check_schema, [])

    quote do
      defstruct unquote(struct_fields)

      def __type__({}) do
        {
          :ref,
          {Exchema.Types.Struct, {__MODULE__, unquote(fields)}},
          unquote(schema_predicates)
        }
      end
    end
  end
end
