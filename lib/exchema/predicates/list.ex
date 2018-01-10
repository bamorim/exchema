defmodule Exchema.Predicates.List do
  def __predicate__(list, opts \\ [])
  def __predicate__(list, _) when not is_list(list) do
    {:error, :not_a_list}
  end
  def __predicate__(list, opts) do
    case Keyword.get(opts, :element_type) do
      nil ->
        :ok
      type ->
        list
        |> Enum.with_index
        |> Enum.map(fn {e, idx} -> {idx, Exchema.errors(e, type)} end)
        |> Enum.filter(fn {_, err} -> length(err) > 0 end)
        |> check_error
    end
  end

  defp check_error([]), do: :ok
  defp check_error(errors) do
    {:error, {:invalid_elements, errors}}
  end
end
