defmodule Exchema do
  @moduledoc """
  Documentation for Exchema.
  """

  alias Exchema.{
    Parser,
    Schema
  }

  @spec parse(map(), Schema.t) :: Parser.result
  def parse(input_map, schema, opts \\ []) do
    Parser.parse(input_map, schema, options(opts))
  end

  defp options(opts) do
    default_options = [
      key_transformers: [&(&1), &to_string/1],
      transformers: [Exchema.Transformers.Type],
    ]

    default_options
    |> Keyword.merge(opts)
  end
end
