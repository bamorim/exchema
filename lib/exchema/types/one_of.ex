defmodule Exchema.Types.OneOf do
  @moduledoc """
  Represents one of the given types.
  Also known as a *sum type*.

  For example:
  ```
  iex> alias Exchema.Types, as: T
  iex> t = {T.OneOf, [T.String, T.Integer]}
  iex> Exchema.is?("string", t)
  true

  iex> Exchema.is?(100, t)
  true

  iex> Exchema.is?(:atom, t)
  false
  ```

  In case it fails, it will just return a invalid_type error.

  If all the types are Structs, use `Exchema.Types.OneStructOf`
  """
  alias Exchema.Predicates

  @doc false
  def __type__({types}) when is_list(types) do
    {:ref, :any, [{{__MODULE__, :predicate}, types}]}
  end

  @doc false
  def predicate(value, types) do
    types
    |> Stream.filter(&Exchema.is?(value, &1))
    |> Enum.at(0)
    |> case do
      nil ->
        {:error, :invalid_type}
      _ ->
        :ok
    end
  end
end
