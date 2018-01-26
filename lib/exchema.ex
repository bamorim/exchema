defmodule Exchema do
  @moduledoc """
  Exchema is a library for defining data structures using refinement types.
  """

  alias Exchema.Type

  @type error :: {Type.predicate_spec, any}

  @spec is?(any, Type.spec, [{atom, any}]) :: boolean
  def is?(val, type, opts \\ []), do: errors(val, type, opts) == []

  @spec errors(any, Type.spec, [{atom, any}]) :: [error]
  def errors(value, type, opts \\ [])
  def errors(_, :any, _), do: []
  def errors(val, {:ref, supertype, predicates}, opts) do
    errors(val, supertype, opts) ++ errors_for(predicates, val, opts)
  end
  def errors(val, type_ref, opts) do
    errors(val, Type.resolve_type(type_ref), opts)
  end

  @spec errors_for([Type.predicate_spec], any, [{atom, any}]) :: [error]
  defp errors_for(predicates, val, opts) when is_list(predicates) do
    predicates
    |> Enum.flat_map(&(predicate_errors(&1, val, opts)))
  end

  @spec predicate_errors(Type.predicate_spec, any, [{atom, any}]) :: [error]
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
end
