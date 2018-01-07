defmodule Exchema.Schema do
  @type field :: [Exchema.Transformer.spec] | t
  @type t :: %{required(any) => field}
end
