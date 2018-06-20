defmodule Exchema.Type do
  @moduledoc """
  This is the contract of a type module.

  To implement your own type you should just implement
  the `___type__/1` callback which receives a tuple with
  your type arguments. If you have a concrete type,
  then it should match on receiving an empty tuple `{}`.
  """
  @type t :: module

  @type predicate_reference :: {module, atom} | atom
  @type predicate_spec :: {predicate_reference, any}
  @type refined_type :: {:ref, t, [predicate_spec]}

  @type type_params :: tuple
  @type type_reference :: Type.t | {Type.t, type_params}

  @type spec :: type_reference | refined_type

  @callback __type__(type_params) :: spec

  @doc "Resolves a type reference into it's definition"
  @spec resolve_type(type_reference) :: spec
  def resolve_type({type, params}) when is_tuple(params) do
    type.__type__(params)
  end
  def resolve_type({type, param}) do
    type.__type__({param})
  end
  def resolve_type(type) do
    type.__type__({})
  end
end
