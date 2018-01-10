defmodule Exchema.Predicates.Fun do
  def __predicate__(val, fun) do
    case fun.(val) do
      true ->
        :ok
      :ok ->
        :ok
      false ->
        {:error, :invalid}
      {:error, e} ->
        {:error, e}
    end
  end
end
