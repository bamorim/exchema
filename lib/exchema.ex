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
  def parse(input_map, schema) do
    schema
    |> Map.to_list
    |> Enum.map(&(construct_field(input_map, &1)))
    |> Enum.reduce(%{}, &fold_result/2)
  end

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

  @spec construct_field(map(), {any, schema_field}) :: {any, transformation_result}
  defp construct_field(input_map, {key, %{} = schema}) do
    parsed =
      input_map
      |> get_value(key)
      |> parse(schema)

    case parsed do
      {:errors, errors} ->
        {key, {:error, {:errors, errors}}}
      _ ->
        {key, parsed}
    end
  end
  defp construct_field(input_map, {key, transformer_specs}) do
    transformers =
      transformer_specs
      |> Enum.map(&fetch_transformer/1)

    new_val =
      input_map
      |> get_value(key)
      |> apply_transformers(transformers)

    {key, new_val}
  end

  @doc "Get key by itself or by stringy-version of it"
  @spec get_value(map, any, [(any -> any)]) :: any
  defp get_value(input_map, key, key_transformers \\ [&(&1), &to_string/1]) do
    key_transformers
    |> Enum.filter(&(Map.has_key?(input_map, &1.(key))))
    |> Enum.map(&(Map.get(input_map, &1.(key))))
    |> List.first
  end

  @spec fetch_transformer(transformer_spec) :: transformer
  defp fetch_transformer({key, options}) do
    fn val -> transform(key, val, options) end
  end

  @spec apply_transformers(any, [transformer]) :: transformation_result
  defp apply_transformers(value, transformers) do
    transformers
    |> Enum.reduce(value, &(apply_transformer(&2, &1)))
  end

  defp apply_transformer({:error, _} = err, _), do: err
  defp apply_transformer(val, transformer) do
    case transformer.(val) do
      :ok ->
        val
      {:ok, new_val} ->
        new_val
      {:error, error} ->
        {:error, error}
      new_val ->
        new_val
    end
  end

  # === Transformers ===

  def transform(:integer, val, _) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} ->
        int
      :error ->
        {:error, :not_a_valid_integer}
    end
  end
  def transform(:integer, val, _) when is_float(val), do: Float.round(val)
  def transform(:integer, val, _) when is_integer(val), do: val
  def transform(:integer, val, _), do: {:error, :not_a_valid_integer}
end
