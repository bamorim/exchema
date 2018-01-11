defmodule Exchema.Coercions do
  @moduledoc """
  Default coercions library
  """

  alias Exchema.Types, as: T
  alias __MODULE__, as: C

  @coerces [
    T.Optional,
    T.Integer,
    T.Float,
    T.Number,
    T.String,
    T.Boolean
  ]

  def coerces?({type, _}), do: coerces?(type)
  def coerces?(type) do
    type in @coerces
  end

  def coerce(nil, {T.Optional, _}), do: nil
  def coerce(other, {T.Optional, type}), do: Exchema.Coercion.coerce(other, type)
  def coerce(input, {type, _}), do: coerce(input, type)
  def coerce(input, T.Integer), do: C.Integer.coerce(input)
  def coerce(input, T.Float), do: C.Float.coerce(input)
  def coerce(input, T.Number), do: C.Float.coerce(input)
  def coerce(input, T.String), do: C.String.coerce(input)
  def coerce(input, T.Boolean), do: C.Boolean.coerce(input)
end
