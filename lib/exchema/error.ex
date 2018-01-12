defmodule Exchema.Error do
  @moduledoc """
  This module contains helpers to deal with Exchema errors.
  """

  alias Exchema.Predicates, as: P

  @doc """
  Flattens a list of errors by the `map` and `list`
  predicate errors and flattening them into a 4-tuple with
  the first element being the path.
  """
  def flattened(errors) do
    errors
    |> Enum.flat_map(&flatten/1)
    |> Enum.map(&reverse_path/1)
  end

  defp flatten(errors, path \\ [])
  defp flatten({{P, :list}, _, {:nested_errors, errors}}, path) do
    flatten({{P, :map}, nil, {:nested_errors, errors}}, path)
  end
  defp flatten({{P, :map}, _, {:nested_errors, errors}}, path) do
    errors
    |> Enum.flat_map(fn {key, key_errors} ->
      key_errors
      |> Enum.flat_map(&(flatten(&1, [key | path])))
    end)
  end
  defp flatten({pred, opt, error}, path) do
    [{path, pred, opt, error}]
  end

  defp reverse_path({path, pred, opt, error}) do
    {Enum.reverse(path), pred, opt, error}
  end
end
