defmodule Exchema do
  @moduledoc """
  Documentation for Exchema.
  """

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
    errors(val, resolve_type(type_ref), opts)
  end

  @spec errors_for([Type.predicate_spec], any, [{atom, any}]) :: [error]
  defp errors_for(predicates, val, opts) when is_list(predicates) do
    predicates
    |> Enum.flat_map(&(predicate_errors(&1, val, opts)))
  end

  @spec predicate_errors(Type.predicate_spec, any, [{atom, any}]) :: [error]
  defp predicate_errors({{mod, fun}, opts}, val, _) do
    case apply(mod, fun, [val, opts]) do
      {:error, err} ->
        [{{mod, fun}, opts, err}]
      _ ->
        []
    end
  end
  defp predicate_errors({pred_key, opts}, val, g_opts) do
    predicate_errors(
      {
        {pred_mod(g_opts), pred_key},
        opts
      },
      val,
      g_opts
    )
  end

  defp pred_mod(g_opts) do
    Keyword.get(g_opts, :predicates)
  end

  @spec resolve_type(Type.type_reference) :: Type.t | Type.refined_type
  defp resolve_type({type, param}) when is_atom(param) do
    type.__type__({param})
  end
  defp resolve_type({type, params}) do
    type.__type__(params)
  end
  defp resolve_type(type) do
    type.__type__({})
  end
end
