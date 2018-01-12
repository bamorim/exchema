defmodule Exchema.Coercions do
  alias Exchema.Types, as: T
  alias __MODULE__, as: C

  @coerces [
    T.Optional,
    T.Integer,
    T.Float,
    T.Number,
    T.String,
    T.Boolean,
    T.Struct,
    T.Date,
    T.Time,
    T.DateTime,
    T.NaiveDateTime
  ]

  @moduledoc """
  Default coercions library

  It coerces #{@coerces |> Enum.map(&to_string/1) |> Enum.join(", ") |> String.replace("Elixir.T.", "")}
  """

  @doc false
  def coerces?({type, _}), do: coerces?(type)
  def coerces?(type) do
    type in @coerces
  end

  def coerce(nil, {T.Optional, _}), do: nil
  def coerce(other, {T.Optional, type}), do: Exchema.Coercion.coerce(other, type)
  def coerce(input, {T.Struct, {mod, fields}}), do: C.Struct.coerce(input, mod, fields)
  def coerce(input, {type, _}), do: coerce(input, type)
  def coerce(input, T.Integer), do: C.Integer.coerce(input)
  def coerce(input, T.Float), do: C.Float.coerce(input)
  def coerce(input, T.Number), do: C.Float.coerce(input)
  def coerce(input, T.String), do: C.String.coerce(input)
  def coerce(input, T.Boolean), do: C.Boolean.coerce(input)
  def coerce(input, T.Date), do: C.Date.coerce(input)
  def coerce(input, T.Time), do: C.Time.coerce(input)
  def coerce(input, T.DateTime), do: C.DateTime.coerce(input)
  def coerce(input, T.NaiveDateTime), do: C.NaiveDateTime.coerce(input)
end
