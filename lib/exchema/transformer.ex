defmodule Exchema.Transformer do
  @moduledoc """
  The interface for a transformer
  """

  @type t :: module
  @type spec :: {any, any}
  @type error :: String.t | atom
  @type result :: :ok | {:ok, any} | {:error, error}

  @callback transform(any, any, any) :: result | :unhandled
end
