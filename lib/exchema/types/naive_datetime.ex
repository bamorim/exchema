defmodule Exchema.Types.NaiveDateTime do
  @moduledoc "Represents NaiveDateTime struct"
  alias Exchema.Predicates

  @doc false
  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, NaiveDateTime}]}
  end
end
