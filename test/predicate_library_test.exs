defmodule PrecicatesLibraryTest do
  use ExUnit.Case

  test "we can pass an atom as refinement and a predicate library" do
    type = {:ref, :any, is_integer: true}
    assert Exchema.is?(1, type, predicates: Predicates)
    refute Exchema.is?("1", type, predicates: Predicates)
  end

  test "we have a default predicate library" do
    type = {:ref, :any, is: :integer}
    assert Exchema.is?(1, type)
    refute Exchema.is?("1", type)
  end

  test "we still have access to the default predicate library when passing a custom library" do
    type = {:ref, :any, is: :integer}
    assert Exchema.is?(1, type, predicates: Predicates)
  end

  test "specified predicate library overrides the default ones" do
    type = {:ref, :any, is: :integer}
    assert [{_, _, :custom_error}] = Exchema.errors("1", type, predicates: Predicates.Overrides)
  end

  test "when passing more than one library, it matches the first one" do
    type = {:ref, :any, is: :integer}
    predicates = [Predicates.Overrides2, Predicates.Overrides]
    assert [{_, _, :custom_error_2}] = Exchema.errors("1", type, predicates: predicates)
  end

  test "when passing more than one library, all are accessible" do
    type = {:ref, :any, is_integer: nil}
    predicates = [Predicates.Overrides, Predicates]
    assert [{_, _, :not_an_integer}] = Exchema.errors("1", type, predicates: predicates)
  end
end
