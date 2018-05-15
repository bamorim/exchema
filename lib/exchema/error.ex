defmodule Exchema.Error do
  @moduledoc """
  This module contains helpers to deal with Exchema errors.
  """

  @doc """
  Flattens a list of errors that follows the `:nested_errors`
  pattern where the error returned follow this structure:

  ```
  {
    {predicate, predicate_opts, {
      :nested_errors,
      [
        {key, error},
        {key, error}
      ]
    }
  }
  ```

  The returned result is a list of a 4-tuple where the
  first element is the path of keys to reach the error and
  the rest is the normal 3-tuple error elements (predicate,
  predicate options and the error itself)
  """
  def flattened(errors) do
    errors
    |> Enum.flat_map(&flatten/1)
    |> Enum.map(&reverse_path/1)
  end

  defp flatten(errors, path \\ [])
  defp flatten({_, _, {:nested_errors, errors}}, path) do
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
