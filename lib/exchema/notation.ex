defmodule Exchema.Notation do
  @moduledoc """
  A DSL for defining types.
  """

  alias __MODULE__, as: N
  @empty {:__block__, [], []}

  defmacro structure(fields) do
    __struct(fields)
  end

  defmacro structure(mod, fields) do
    wrapper(mod, __struct(fields), @empty)
  end

  defmacro structure(mod, fields, [do: block]) do
    wrapper(mod, __struct(fields), block)
  end

  defmacro type(refinements) do
    __type(refinements)
  end

  defmacro type(mod, refinements) do
    wrapper(mod, __type(refinements), @empty)
  end

  defmacro type(mod, refinements, [do: block]) do
    wrapper(mod, __type(refinements), block)
  end

  defmacro subtype(suptype, refinements) do
    __subtype(suptype, refinements)
  end

  defmacro subtype(mod, suptype, refinements) do
    wrapper(mod, __subtype(suptype, refinements), @empty)
  end

  defmacro subtype(mod, suptype, refinements, [do: block]) do
    wrapper(mod, __subtype(suptype, refinements), block)
  end

  defmacro newtype(mod) do
    wrapper(mod, __subtype(:any, []), @empty)
  end

  defmacro newtype(mod, [do: block]) do
    wrapper(mod, __subtype(:any, []), block)
  end

  defmacro newtype(mod, suptype) do
    wrapper(mod, __subtype(suptype, []), @empty)
  end

  defmacro newtype(mod, suptype, [do: block]) do
    wrapper(mod, __subtype(suptype, []), block)
  end

  defmacro refine(refinements) do
    N.Subtype.__refine(refinements)
  end

  defp wrapper(nil, content, nil), do: content
  defp wrapper(nil, content, extra) do
    quote do
      unquote(content)
      unquote(extra)
    end
  end
  defp wrapper(mod, content, extra) do
    quote do
      defmodule unquote(mod) do
        unquote(wrapper(nil, content, extra))
      end
    end
  end

  defp __struct(fields) do
    N.Struct.__struct(fields)
  end

  defp __type(refinements) do
    N.Type.__type(refinements)
  end

  defp __subtype(suptype, refinements) do
    N.Subtype.__subtype(suptype, refinements)
  end
end
