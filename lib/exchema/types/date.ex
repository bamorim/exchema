defmodule Exchema.Types.Date do
  @moduledoc "Represents Date struct"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, Date}]}
  end
end
