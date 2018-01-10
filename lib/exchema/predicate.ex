defmodule Exchema.Predicate do
  @type t :: module
  @type options :: any
  @type spec :: {t, options}
  @type error :: any
  @type result :: :ok | {:error, error}

  @callback __predicate__(any, options) :: result
end
