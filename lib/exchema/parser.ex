defmodule Exchema.Parser do
  @moduledoc """
  Parses a input to a given schema or module that
  defines an schema
  """
  alias Exchema.{
    Transformer,
    Schema
  }

  @type field_path :: [any]
  @type field_error :: {field_path, Transformer.error}
  @type result :: map() | {:errors, [field_error]}

  @spec parse(map(), Schema.t, [atom: any]) :: result
  def parse(input, schema, opts) when is_atom(schema) do
    parse(input, schema.__exchema__(), opts)
  end
  def parse(input_map, schema, opts) do
    schema
    |> Map.to_list
    |> Enum.map(&(construct_field(input_map, &1, opts)))
    |> Enum.reduce(%{}, &fold_result/2)
  end

  # == Fold Result ==
  @spec fold_result({any, Transformer.result}, map()) :: map() | result
  defp fold_result({key, {:error, err}}, %{}), do: {:errors, add_error([], key, err)}
  defp fold_result({key, {:error, err}}, {:errors, e}), do: {:errors, add_error(e, key, err)}
  defp fold_result({key, val}, %{} = result), do: Map.put_new(result, key, val)
  defp fold_result(_, r), do: r

  @spec add_error([field_error], any, Transformer.error) :: [field_error]
  defp add_error(errors, key, {:errors, nested_errors}) do
    (
      nested_errors
      |> Enum.map(&(flatten_error(key, &1)))
    ) ++ errors
  end
  defp add_error(errors, key, err), do: [{[key], err} | errors]

  @spec flatten_error(any, field_error) :: field_error
  defp flatten_error(top_key, {path, err}), do: {[top_key | path], err}

  # == Transform each field ==
  @spec construct_field(map(), {any, Schema.field}, [atom: any]) :: {any, Transformer.result}
  defp construct_field(input_map, {key, field}, opts) do
    result =
      input_map
      |> get_value(key, Keyword.get(opts, :key_transformers))
      |> transform(field, opts)

    {key, result}
  end

  @spec get_value(map, any, [(any -> any)]) :: any
  defp get_value(input_map, key, key_transformers) do
    key_transformers
    |> Stream.filter(&(Map.has_key?(input_map, &1.(key))))
    |> Stream.map(&(Map.get(input_map, &1.(key))))
    |> Enum.to_list
    |> List.first
  end

  @spec transform(any, Schema.field, [atom: any]) :: Transformer.result
  defp transform(input, %{} = schema, opts) do
    parsed = parse(input, schema, opts)

    case parsed do
      {:errors, errors} ->
        {:error, {:errors, errors}}
      _ ->
        parsed
    end
  end
  defp transform(input, transformer_specs, opts) do
    Enum.reduce(
      transformer_specs,
      input,
      &(apply_transformer(&2, &1, Keyword.get(opts, :transformers)))
    )
  end

  @spec apply_transformer(any, Transformer.spec, [Transformer.t]) :: Transformer.result
  defp apply_transformer({:error, _} = err, _, _), do: err
  defp apply_transformer(val, transformer_spec, transformers) do
    case do_apply_transformer(val, transformer_spec, transformers) do
      :ok ->
        val
      {:ok, new_val} ->
        new_val
      {:error, error} ->
        {:error, error}
    end
  end

  @spec do_apply_transformer(any, Transformer.spec, [Transformer.t]) :: Transformer.result
  defp do_apply_transformer(val, {key, opts}, transformers) do
    transformers
    |> Stream.map(&(&1.transform(key, val, opts)))
    |> Stream.filter(&(&1 != :unhandled))
    |> Stream.take(1)
    |> Enum.to_list
    |> List.first
  end
end
