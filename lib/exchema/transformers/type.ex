defmodule Exchema.Transformers.Type do
  @behaviour Exchema.Transformer

  def transform(:type, nil, _), do: {:ok, nil}
  def transform(:type, val, :integer) when is_integer(val), do: {:ok, val}
  def transform(:type, val, :integer), do: coerce(val, :integer)
  def transform(_,_,_), do: :unhandled

  defp coerce(val, :integer) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} ->
        {:ok, int}
      :error ->
        {:error, :not_a_valid_integer}
    end
  end
  defp coerce(val, :integer) when is_float(val), do: {:ok, Float.round(val)}
  defp coerce(val, :integer) when is_integer(val), do: {:ok, val}
  defp coerce(_, :integer), do: {:error, :not_a_valid_integer}
end
