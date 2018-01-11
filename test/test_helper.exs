defmodule Predicates do
  def is_integer(value, _) when is_integer(value), do: :ok
  def is_integer(_,_), do: {:error, :not_an_integer}

  def min(value, min) when value >= min, do: :ok
  def min(_, _), do: {:error, :should_be_bigger}

  defmodule Overrides do
    def is(_, _), do: {:error, :custom_error}
  end

  defmodule Overrides2 do
    def is(_, _), do: {:error, :custom_error_2}
  end
end

ExUnit.start()
