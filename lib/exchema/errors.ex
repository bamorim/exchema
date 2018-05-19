defmodule Exchema.Errors do
  @moduledoc false

  def errors(value, type, opts \\ [])
  def errors(_, :any, _), do: []
  def errors(val, {:ref, supertype, predicates}, opts) do
    errors(val, supertype, opts) ++ predicates_errors(predicates, val, opts)
  end
  def errors(val, type_ref, opts) do
    errors(val, Exchema.Type.resolve_type(type_ref), opts)
  end

  def flatten_errors(errors) do
    errors
    |> Enum.flat_map(&flatten_error/1)
    |> Enum.map(&reverse_path/1)
  end

  defp predicates_errors(predicates, val, opts) when is_list(predicates) do
    predicates
    |> Enum.flat_map(&(predicate_errors(&1, val, opts)))
  end

  defp predicate_errors({{mod, fun}, opts}, val, _) do
    case apply(mod, fun, [val, opts]) do
      false ->
        [{{mod, fun}, opts, :invalid}]
      errors when is_list(errors) ->
        errors
        |> Enum.map(&(format_predicate_error(mod, fun, opts, &1)))
      {:error, _} = error ->
        [format_predicate_error(mod, fun, opts, error)]
      _ ->
        []
    end
  end
  defp predicate_errors({pred_key, opts}, val, g_opts) do
    predicate_errors(
      {
        {pred_mod(g_opts, pred_key), pred_key},
        opts
      },
      val,
      g_opts
    )
  end

  defp format_predicate_error(mod, fun, opts, {:error, err}) do
    {{mod, fun}, opts, err}
  end

  defp pred_mod(g_opts, pred_key) do
    g_opts
    |> pred_mods
    |> Enum.filter(&(:erlang.function_exported(&1, pred_key, 2)))
    |> List.first
  end

  defp pred_mods(g_opts) do
    [
      (Keyword.get(g_opts, :predicates) || []),
      (Application.get_env(:exchema, :predicates) || []),
      Exchema.Predicates
    ] |> List.flatten
  end

  defp flatten_error(errors, path \\ [])
  defp flatten_error({_, _, {:nested_errors, errors}}, path) do
    errors
    |> Enum.flat_map(fn {key, key_errors} ->
      key_errors
      |> Enum.flat_map(&(flatten_error(&1, [key | path])))
    end)
  end
  defp flatten_error({pred, opt, error}, path) do
    [{path, pred, opt, error}]
  end

  defp reverse_path({path, pred, opt, error}) do
    {Enum.reverse(path), pred, opt, error}
  end
end
