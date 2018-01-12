defmodule Exchema.Types.Optional do
  @moduledoc """
  Represents a value which can be nil

  You can specify the type when it is not nil, so if you want an
  integer that can be nil you can represent it with
  `{Exchema.Types.Optional, Exchema.Types.Integer}`

  With that, either `nil` and `1` are valid values, however
  `"this"` is not a valid one.
  """

  @doc false
  def __type__({type}) do
    {:ref, :any, [{{__MODULE__, :pred}, type}]}
  end

  @doc false
  def pred(nil, _), do: :ok
  def pred(val, type) do
    case Exchema.errors(val, type) do
      [] ->
        :ok
      errors ->
        {:error, errors}
    end
  end
end
