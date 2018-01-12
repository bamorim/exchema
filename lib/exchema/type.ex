defmodule Exchema.Type do
  @moduledoc """
  This is the contract of a type module.

  To implement your own type you should just implement
  the `___type__/1` callback which receives a tuple with
  your type arguments. If you have a concrete type,
  then it should match on receiving an empty tuple `{}`.
  """
  @type t :: module

  @type error :: {:error, any}
  @type predicate_failure :: false | error | [error, ...]
  @type predicate_success :: :ok | true | []
  @type predicate_result :: predicate_failure | predicate_success
  @type predicate_fun :: ((any, any) -> predicate_result)
  @type predicate :: {module, atom} | atom
  @type predicate_spec :: {predicate, any}

  @type type_params :: tuple
  @type type_reference :: t | {t, type_params}
  @type refined_type :: {:ref, t, [predicate_spec]}
  @type type_spec :: type_reference | refined_type

  @callback __type__(type_params) :: type_spec

  @spec resolve_type(Type.type_reference) :: Type.t | Type.refined_type
  def resolve_type({type, param}) when is_atom(param) do
    type.__type__({param})
  end
  def resolve_type({type, params}) do
    type.__type__(params)
  end
  def resolve_type(type) do
    type.__type__({})
  end
end
