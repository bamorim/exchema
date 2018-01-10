defmodule Exchema do
  @moduledoc """
  Documentation for Exchema.
  """

  @type error :: {Predicate.t, atom, any, Predicate.options}

  @spec is?(any, Type.spec) :: boolean
  def is?(val, type), do: errors(val, type) == []

  @spec errors(any, Type.spec) :: [error]
  def errors(_, :any), do: []
  def errors(val, {:ref, supertype, predicates}) do
    errors(val, supertype) ++ errors_for(predicates, val)
  end
  def errors(val, type_ref) do
    errors(val, resolve_type(type_ref))
  end

  @spec errors_for([Predicate.spec], any) :: [error]
  defp errors_for(predicates, val) when is_list(predicates) do
    predicates
    |> Enum.flat_map(&(predicate_errors(&1, val)))
  end

  @spec predicate_errors(Predicate.spec, any) :: [error]
  defp predicate_errors({mod, opts}, val) do
    case mod.__predicate__(val, opts) do
      {:error, err} ->
        [{mod, err}]
      _ ->
        []
    end
  end

  @spec is_error?(Predicate.result) :: boolean
  defp is_error?({:error, _}), do: true
  defp is_error?(_, _), do: false

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
