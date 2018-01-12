defmodule Exchema.Struct do
  @moduledoc """
  DSL to define a type struct. The idea is to be a replacement
  for defstruct.

  It general, it is similar to defstruct but instead of defining
  the default values, you define the types of your fields.

  ## Example

      defmodule MyRange do
        use Exchema.Struct, fields: [
          start: Exchema.Types.Integer,
          end: Exchema.Types.Integer
        ], check_schema: [
          fun: fn %{start: s, end: e} ->
            s <= e
          end
        ]
      end

      # Now you can use it as a struct
      range = %MyRange{start: 1, end: 2}

      # But you can also use it as a type
      true = Exchema.is?(range, MyRange)

      # And this will check the constraints you specified
      false = Exchema.is?(%MyRange{start: "0", end: "1"}, MyRange)

  ## `:fields`

  The fields option specifies the types of the fields you have
  and also defines them as the struct fields.

  ## `:check_schema`

  This option is a list of predicates to validate the whole
  schema against. It is useful to check constraints between
  fields, i.e. password confirmation.
  """

  @doc false
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
