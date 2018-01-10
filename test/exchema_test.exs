defmodule ExchemaTest do
  use ExUnit.Case
  doctest Exchema

  @moduletag :basic

  defmodule IntegerPredicate do
    @behaviour Exchema.Predicate
    def __predicate__(value, _) when is_integer(value), do: :ok
    def __predicate__(_,_), do: {:error, :not_an_integer}
  end

  defmodule MinPredicate do
    @behaviour Exchema.Predicate
    def __predicate__(value, min) when value >= min, do: :ok
    def __predicate__(_, _), do: {:error, :should_be_bigger}
  end

  defmodule IntegerType do
    @behaviour Exchema.Type
    def __type__(_), do: {:ref, :any, [{IntegerPredicate, nil}]}
  end

  defmodule PositiveIntegerType do
    @behaviour Exchema.Type
    def __type__(_), do: {:ref, IntegerType, [{MinPredicate, 0}]}
  end

  defmodule ListType do
    defmodule ListPredicate do
      def __predicate__(value, _) when is_list(value), do: :ok
      def __predicate__(_, _), do: {:error, :not_a_list}
    end
    defmodule ListTypePredicate do
      def __predicate__(list, inner_type) when is_list(list) do
        list
        |> Enum.all?(&(Exchema.is?(&1, inner_type)))
        |> msg
      end
      def __predicate__(_, _), do: msg(false)

      defp msg(true), do: :ok
      defp msg(false), do: {:error, :invalid_list_item_type}
    end

    def __type__({inner_type}) do
      {:ref, :any, [{ListPredicate, nil}, {ListTypePredicate, inner_type}]}
    end
  end

  defmodule IntegerListType do
    def __type__(_), do: {ListType, IntegerType}
  end

  test "basic type check" do
    assert Exchema.is?(0, IntegerType)
    assert Exchema.is?(-1, IntegerType)
    refute Exchema.is?("1", IntegerType)
  end

  test "type refinement" do
    assert Exchema.is?(0, PositiveIntegerType)
    refute Exchema.is?(-1, PositiveIntegerType)
  end

  test "type error" do
    assert [{MinPredicate, :should_be_bigger}] = Exchema.errors(-1, PositiveIntegerType)
  end

  @tag :only
  test "parametric types" do
    assert Exchema.is?([1,2,3], {ListType, IntegerType})
    assert Exchema.is?([], {ListType, IntegerType})
    refute Exchema.is?(1, {ListType, IntegerType})
    refute Exchema.is?([1, "2", 3], {ListType, IntegerType})
    refute Exchema.is?(["1", "2", "3"], {ListType, IntegerType})
  end

  test "parametric defined types" do
    assert Exchema.is?([1,2,3], IntegerListType)
    assert Exchema.is?([], IntegerListType)
    refute Exchema.is?(1, IntegerListType)
    refute Exchema.is?([1, "2", 3], IntegerListType)
    refute Exchema.is?(["1", "2", "3"], IntegerListType)
  end
end
