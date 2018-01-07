defmodule Exchema.Transformer do
  @callback transform(any, any, any) :: {:ok, any} | {:error, any} | :unhandled
end
