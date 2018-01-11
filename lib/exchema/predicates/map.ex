defmodule Exchema.Predicates.Map do
  @moduledoc false

  def map(%{} = map, opts), do: do_map(map, opts)
  def map(_, _), do: {:error, :not_a_map}

  defp do_map(map, opts) do
    fields = Keyword.get(opts, :fields)
    keys = Keyword.get(opts, :keys)
    values = Keyword.get(opts, :values)
    result =
      {:ok, map}
      |> check_map_fields(fields)
      |> check_map_keys(keys)
      |> check_map_values(values)

    case result do
      {:ok, _} ->
        :ok
      _ ->
        result
    end
  end

  defp check_map_fields({:error, err}, _), do: {:error, err}
  defp check_map_fields({:ok, map}, nil), do: {:ok, map}
  defp check_map_fields({:ok, map}, fields) do
    case map_fields_errors(map, fields) do
      {:error, errors} ->
        {:error, errors}
      _ ->
        {:ok, map}
    end
  end

  defp check_map_keys({:error, err}, _), do: {:error, err}
  defp check_map_keys({:ok, map}, nil), do: {:ok, map}
  defp check_map_keys({:ok, map}, key_type) do
    case map_key_errors(map, key_type) do
      {:error, errors} ->
        {:error, errors}
      _ ->
        {:ok, map}
    end
  end

  defp check_map_values({:error, err}, _), do: {:error, err}
  defp check_map_values({:ok, map}, nil), do: {:ok, map}
  defp check_map_values({:ok, map}, values) do
    case map_value_errors(map, values) do
      {:error, errors} ->
        {:error, errors}
      _ ->
        {:ok, map}
    end
  end

  defp map_fields_errors(map, fields) do
    fields
    |> Enum.flat_map(&(map_field_errors(map, &1)))
    |> nested_errors
  end

  defp map_field_errors(map, {key, type}) do
    case Exchema.errors(Map.get(map, key), type) do
      [] ->
        []
      errors ->
        [{key, errors}]
    end
  end

  defp map_key_errors(map, key_type) do
    map
    |> Map.keys
    |> Enum.flat_map(&(Exchema.errors(&1, key_type)))
    |> nested_errors(:key_errors)
  end

  defp map_value_errors(map, key_type) do
    map
    |> Map.values
    |> Enum.flat_map(&(Exchema.errors(&1, key_type)))
    |> nested_errors(:value_errors)
  end

  defp nested_errors(errors, error_key \\ :nested_errors)
  defp nested_errors([], _), do: :ok
  defp nested_errors(errors, error_key) do
    {:error, {error_key, errors}}
  end
end
