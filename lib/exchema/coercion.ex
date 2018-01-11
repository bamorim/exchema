defmodule Exchema.Coercion do
  @moduledoc """
  Automagically coercion for Exchema Types

  This will probable be extracted into its own library later.
  """

  def coerce(input, :any), do: input
  def coerce(input, type) when is_atom(type) do
    if coerce_mod(type) do
      coerce_mod(type).coerce(input)
    else
      coerce(input, expand(type))
    end
  end
  def coerce(input, {:ref, supertype, _}) do
    coerce(input, supertype)
  end

  defp expand(type), do: type.__type__({})

  defp coerce_mod(type) do
    mod = Module.concat(ExchemaCoercion, type)
    if :erlang.function_exported(mod, :coerce, 1) do
      mod
    else
      nil
    end
  end

  defmacro __using__(fun) do
    quote do
      require Exchema.Coercion
      Exchema.Coercion.defcoercion(unquote(__CALLER__.module), unquote(fun))
    end
  end

  defmacro defcoercion(type, fun) do
    quote do
      defmodule Module.concat(ExchemaCoercion, unquote(type)) do
        def coerce(input) do
          unquote(fun).(input)
        end
      end
    end
  end
end
