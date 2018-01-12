defmodule Exchema.Coercions.DateTime do
  @moduledoc false

  def coerce(input) when is_binary(input) do
    case DateTime.from_iso8601(input) do
      {:ok, v, _} -> v
      _ -> input
    end
  end
  def coerce(%NaiveDateTime{} = input) do
    case DateTime.from_naive(input, "Etc/UTC") do
      {:ok, v} -> v
      _ -> input
    end
  end
  def coerce(%Date{} = input) do
    with date <- Date.to_erl(input),
         {:ok, naive} <- NaiveDateTime.from_erl({date, {0, 0, 0}}),
         {:ok, final} <- DateTime.from_naive(naive, "Etc/UTC"),
         do: final, else: (_ -> input)
  end
  def coerce(i), do: i
end
