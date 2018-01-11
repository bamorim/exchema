defmodule ExchemaTest do
  use ExUnit.Case
  doctest Exchema

  @moduletag :basic

  defmodule Predicates do
    def is_integer(value, _) when is_integer(value), do: :ok
    def is_integer(_,_), do: {:error, :not_an_integer}

    def min(value, min) when value >= min, do: :ok
    def min(_, _), do: {:error, :should_be_bigger}
  end

  defmodule IntegerType do
    @behaviour Exchema.Type
    def __type__(_), do: {:ref, :any, [{{Predicates, :is_integer}, nil}]}
  end

  defmodule PositiveIntegerType do
    @behaviour Exchema.Type
    def __type__(_), do: {:ref, IntegerType, [{{Predicates, :min}, 0}]}
  end

  defmodule ListType do
    def __type__({inner_type}) do
      {:ref, :any, [{{__MODULE__, :predicate}, inner_type}]}
    end

    def predicate(list, inner_type) when is_list(list) do
      list
      |> Enum.all?(&(Exchema.is?(&1, inner_type)))
      |> msg
    end
    def predicate(_, _), do: msg(false)

    defp msg(true), do: :ok
    defp msg(false), do: {:error, :invalid_list_item_type}
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
    assert [{{Predicates, :min}, 0, :should_be_bigger}] = Exchema.errors(-1, PositiveIntegerType)
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

  test "we can pass type refinement directly" do
    type = {:ref, IntegerType, [{{Predicates, :min}, 0}]}
    assert Exchema.is?(1, type)
    refute Exchema.is?(-1, type)
  end

  test "we can pass an atom as refinement and a predicate library" do
    type = {:ref, :any, is_integer: true}
    assert Exchema.is?(1, type, predicates: Predicates)
    refute Exchema.is?("1", type, predicates: Predicates)
  end
end
