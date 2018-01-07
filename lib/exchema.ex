defmodule Exchema do
  @moduledoc """
  Documentation for Exchema.
  """

  @type transformer_id :: any
  @type transformer_spec :: {transformer_id, transformer_args}
  @type transformer_args :: [any]

  @type error :: String.t | atom
  @type transformation_result :: :ok | {:ok, any} | {:error, error}
  @type transformer :: (any, transformer_args -> transformation_result)

  @type schema_field :: [transformer_spec] | schema
  @type schema :: %{required(any) => schema_field}
  @type field_error :: {[any], error}
  @type parse_result :: map() | {:errors, [field_error]}

  @spec parse(map(), schema) :: parse_result
  def parse(input_map, schema, opts \\ []) do
    schema
    |> Map.to_list
    |> Enum.map(&(construct_field(input_map, &1, options(opts))))
    |> Enum.reduce(%{}, &fold_result/2)
  end

  defp options(opts) do
    default_options = [
      key_transformers: [&(&1), &to_string/1],
      transformers: [Exchema.Transformers.Type],
    ]

    default_options
    |> Keyword.merge(opts)
  end

  # == Fold Result ==
  @spec fold_result({any, transformation_result}, map()) :: map() | parse_result
  defp fold_result({key, {:error, err}}, %{}), do: {:errors, add_error([], key, err)}
  defp fold_result({key, {:error, err}}, {:errors, e}), do: {:errors, add_error(e, key, err)}
  defp fold_result({key, val}, %{} = result), do: Map.put_new(result, key, val)
  defp fold_result(_, r), do: r

  @spec add_error([field_error], any, error) :: [field_error]
  defp add_error(errors, key, {:errors, nested_errors}) do
    (
      nested_errors
      |> Enum.map(&(flatten_error(key, &1)))
    ) ++ errors
  end
  defp add_error(errors, key, err), do: [{[key], err} | errors]

  defp flatten_error(top_key, {path, err}), do: {[top_key | path], err}

  # == Transform each field ==
  @spec construct_field(map(), {any, schema_field}, [atom: any]) :: {any, transformation_result}
  defp construct_field(input_map, {key, definition}, opts) do
    result =
      input_map
      |> get_value(key, Keyword.get(opts, :key_transformers))
      |> transform(definition, opts)

    {key, result}
  end

  @spec get_value(map, any, [(any -> any)]) :: any
  defp get_value(input_map, key, key_transformers) do
    key_transformers
    |> Enum.filter(&(Map.has_key?(input_map, &1.(key))))
    |> Enum.map(&(Map.get(input_map, &1.(key))))
    |> List.first
  end

  @spec transform(any, schema_field, [atom: any]) :: transformation_result
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

  @spec apply_transformer(any, transformer_spec, [transformer]) :: transformation_result
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

  defp do_apply_transformer(val, {key, opts}, transformers) do
    transformers
    |> Stream.map(&(&1.transform(key, val, opts)))
    |> Stream.filter(&(&1 != :unhandled))
    |> Stream.take(1)
    |> Enum.to_list
    |> List.first
  end
end
