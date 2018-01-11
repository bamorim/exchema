defmodule Exchema.Types.Optional do
  def __type__({}), do: __type__({:any})
  def __type__({type}) do
    {:ref, :any, [{{__MODULE__, :pred}, type}]}
  end

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
