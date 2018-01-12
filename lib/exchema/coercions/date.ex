defmodule Exchema.Coercions.Date do
  @moduledoc false

  def coerce(input) when is_binary(input) do
    case Date.from_iso8601(input) do
      {:ok, v} -> v
      _ -> input
    end
  end
  def coerce(%NaiveDateTime{} = input) do
    NaiveDateTime.to_date(input)
  end
  def coerce(%DateTime{} = input) do
    DateTime.to_date(input)
  end
  def coerce(i), do: i
end
