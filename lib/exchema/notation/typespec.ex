defmodule Exchema.Notation.Typespec do
  def set_typespec(mod) do
    unless type_t_defined(mod) do
      define_type_t(mod)
    end
  end

  defp type_t_defined(mod) do
    if Version.match?(System.version(), ">= 1.7.0") do
      Module.defines_type?(mod, {:t, 0})
    else
      mod
      |> Module.get_attribute(:type)
      |> Enum.any?(&is_type_t/1)
    end
  end

  defp define_type_t(mod) do
    mod
    |> Module.get_attribute(:super_type)
    |> typespec_for_type()
    |> define_type(mod)
  end

  defp is_type_t({:type, {:::, _, [{:t, _, _} | _]}, _}), do: true
  defp is_type_t(_), do: false

  defp typespec_for_type({Exchema.Types.Struct, {_, fields}}) do
    {:%, nil,
     [
       {:__MODULE__, [], Elixir},
       {:%{}, [],
        Enum.map(fields, fn {field, type} ->
          {field, typespec_for_type(type)}
        end)}
     ]}
  end

  defp typespec_for_type({Exchema.Types.List, type}) do
    quote do
      list(unquote(typespec_for_type(type)))
    end
  end

  defp typespec_for_type({Exchema.Types.Map, {key, val}}) do
    quote do
      %{optional(unquote(typespec_for_type(key))) => unquote(typespec_for_type(val))}
    end
  end

  defp typespec_for_type({Exchema.Types.Optional, type}) do
    quote do
      nil | unquote(typespec_for_type(type))
    end
  end

  defp typespec_for_type({Exchema.Types.OneOf, types}) do
    typespec_for_type({Exchema.Types.OneStructOf, types})
  end

  defp typespec_for_type({Exchema.Types.OneStructOf, [type]}) do
    typespec_for_type(type)
  end

  defp typespec_for_type({Exchema.Types.OneStructOf, types}) do
    types
    |> Enum.map(&typespec_for_type/1)
    |> Enum.reduce(fn x, acc ->
      quote do
        unquote(x) | unquote(acc)
      end
    end)
  end

  defp typespec_for_type({mod, {single_arg}}) do
    typespec_for_type({mod, single_arg})
  end

  defp typespec_for_type(mod) when is_atom(mod) do
    case to_string(mod) do
      "Elixir.Exchema.Types." <> rest ->
        exchema_typespec(rest)

      "Elixir." <> _ ->
        quote do
          unquote(mod).t
        end

      _ ->
        {:any, [], []}
    end
  end

  defp typespec_for_type({:ref, sup, _}) do
    typespec_for_type(sup)
  end

  defp typespec_for_type(_) do
    {:any, [], []}
  end

  defp define_type(tspec, mod) do
    Module.eval_quoted(
      mod,
      quote do
        @type t :: unquote(tspec)
      end
    )
  end

  @ex_direct ~w(Atom Boolean Integer Number Map Struct Tuple)
  @ex_modules ~w(Date DateTime NaiveDateTime Time)

  defp exchema_typespec(type) when type in @ex_direct, do: from_str(type)
  defp exchema_typespec(type) when type in @ex_modules, do: from_mod(type)
  defp exchema_typespec("String"), do: simple(:binary)
  defp exchema_typespec("Float" <> _), do: simple(:float)
  defp exchema_typespec("Integer.Positive"), do: simple(:pos_integer)
  defp exchema_typespec("Integer.Negative"), do: simple(:neg_integer)
  defp exchema_typespec("Integer.NonNegative"), do: simple(:non_neg_integer)
  defp exchema_typespec(_), do: :any

  defp simple(atom) do
    {atom, [], []}
  end

  defp from_str(str) do
    str
    |> String.downcase()
    |> String.to_atom()
    |> simple
  end

  defp from_mod(mod) do
    mod = :"Elixir.#{mod}"

    quote do
      unquote(mod).t
    end
  end
end
