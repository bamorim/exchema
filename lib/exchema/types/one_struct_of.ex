defmodule Exchema.Types.OneStructOf do
  @moduledoc """
  This is a specification of the `Exchema.Types.OneOf` type.

  This optmizes the type discobery by checking the data against the
  module `.__struct__` directly.

  This also has better error reporting, because it returns the errors of
  the given type.
  """
  alias Exchema.Predicates

  @doc false
  def __type__({types}) when is_list(types) do
    {:ref, :any, [{{__MODULE__, :predicate}, types}]}
  end

  @doc false
  def predicate(%struct{} = value, structs) do
    if struct in structs do
      Exchema.errors(value, struct)
      |> Enum.map(fn {_, _, error} ->
        {:error, error}
      end)
    else
      {:error, :invalid_struct}
    end
  end
  def predicate(_, _), do: {:error, :invalid_struct}
end
