defmodule Exchema.Coercions.NaiveDateTime do
  @moduledoc false

  def coerce(input) when is_binary(input) do
    case NaiveDateTime.from_iso8601(input) do
      {:ok, v} -> v
      _ -> input
    end
  end
  def coerce(%DateTime{} = input) do
    DateTime.to_naive(input)
  end
  def coerce(%Date{} = input) do
    with date <- Date.to_erl(input),
         {:ok, naive} <- NaiveDateTime.from_erl({date, {0, 0, 0}}),
         do: naive, else: (_ -> input)
  end
  def coerce(i), do: i
end
