defmodule Exchema do
  @moduledoc """
  Exchema is a library for defining data structures using refinement types.

  Exchema is split in some components:

  * `Exchema` - the main module. It does type checking and deal with type checking
    errors.
  * `Exchema.Predicates` - The default predicate library you can use to refine your
    types. It's just a bunch of 2-arity functions that receives the value and some
    options.
  * `Exchema.Notation` - a DSL for defining types.
  * `Exchema.Coercion` - Use the type specs to magically coerces input values into
  the defined datatypes. (It should probably move into another library in the future)

  It also comes with a series of pre-defined types you can check under `Exchema.Types`
  namespace.
  """

  @type error :: {Type.predicate_spec, any, any}
  @type flattened_error :: {[any], Type.predicate_spec, any, any}

  @spec is?(any, Type.spec, [{atom, any}]) :: boolean
  def is?(val, type, opts \\ []), do: errors(val, type, opts) == []

  @spec errors(any, Type.spec, [{atom, any}]) :: [error]
  defdelegate errors(val, type, opts \\ []), to: Exchema.Errors

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
  @spec flatten_errors([error]) :: [flattened_error]
  defdelegate flatten_errors(errors), to: Exchema.Errors
end