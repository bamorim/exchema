defmodule Exchema.Macros.NumericType do
  @moduledoc false

  defmacro __using__([type: type]) do
    quote do
      @doc false
      alias __MODULE__, as: ThisType
      alias Exchema.Predicates

      @type t :: unquote(type)()
      def __type__({}) do
        {:ref, :any, [{{Predicates, :is}, unquote(type)}]}
      end

      defmodule Positive do
        @moduledoc "Represents a positive #{unquote(type)}"

        @type t :: unquote(type)()
        def __type__({}) do
          {:ref, ThisType, [{{Predicates, :gt}, 0}]}
        end
      end

      defmodule Negative do
        @moduledoc "Represents a negative #{unquote(type)}"

        @type t :: unquote(type)()
        def __type__({}) do
          {:ref, ThisType, [{{Predicates, :lt}, 0}]}
        end
      end

      defmodule NonPositive do
        @moduledoc "Represents a non positive #{unquote(type)}"

        @type t :: unquote(type)()
        def __type__({}) do
          {:ref, ThisType, [{{Predicates, :lte}, 0}]}
        end
      end

      defmodule NonNegative do
        @moduledoc "Represents a non negative #{unquote(type)}"

        @type t :: unquote(type)()
        def __type__({}) do
          {:ref, ThisType, [{{Predicates, :gte}, 0}]}
        end
      end
    end
  end
end
