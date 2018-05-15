defmodule Exchema.Notation.Subtype do
  def __subtype(suptype, refinements) do
    quote do
      @super_type unquote(suptype)
      @refinements [:erlang.term_to_binary(unquote(refinements_for(refinements)))]
      @before_compile Exchema.Notation.Subtype
    end
  end

  def __refine(refinements) do
    quote do
      @refinements [
        :erlang.term_to_binary(unquote(refinements_for(refinements))) |
        @refinements
      ]
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      unquote(__define_type())
    end
  end

  def __define_type do
    quote do
      def __type__({}) do
        predicates =
          @refinements
          |> case do
               [] -> []
               list ->
                 list
                 |> Enum.map(&:erlang.binary_to_term/1)
                 |> Enum.reduce(&(&1 ++ &2))
             end
        {:ref, @super_type, predicates}
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
