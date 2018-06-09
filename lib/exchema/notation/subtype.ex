defmodule Exchema.Notation.Subtype do
  @moduledoc false
  def __subtype(suptype, refinements_spec) do
    quote do
      @super_type unquote(suptype)
      @refinement_count 0
      unquote(__add_refinements(refinements_spec))
      @doc false
      def __exchema_refinement_0(), do: []
      @before_compile Exchema.Notation.Subtype
    end
  end

  def __add_refinements(refinements_spec) do
    refinements = Macro.escape(refinements_for(refinements_spec))
    base_fname = "__exchema_refinement"
    quote bind_quoted: [refinements: refinements, base_fname: base_fname] do
      @refinement_count (@refinement_count + 1)
      @doc false
      def unquote(:"#{base_fname}_#{@refinement_count}")() do
        unquote(:"#{base_fname}_#{@refinement_count-1}")() ++ unquote(refinements)
      end
    end
  end

  defmacro __before_compile__(%{module: mod}) do
    Exchema.Notation.Typespec.set_typespec(mod)
    base_fname = "__exchema_refinement"
    quote bind_quoted: [base_fname: base_fname] do
      @doc false
      def __type__({}) do
        {
          :ref,
          @super_type,
          unquote(:"#{base_fname}_#{@refinement_count}")()
        }
      end
    end
  end

  defp refinements_for({sym, _, _} = fun) when sym in [:&, :fn] do
    quote do
      [fun: unquote(fun)]
    end
  end
  defp refinements_for(preds) when is_list(preds), do: preds
  defp refinements_for(preds) do
    raise "Invalid predicate: #{preds}"
  end
end
