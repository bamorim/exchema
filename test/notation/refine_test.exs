defmodule Notation.RefineTest do
  use ExUnit.Case
  import Exchema.Notation
  alias Exchema.Types, as: T

  subtype Type, T.Integer, [] do
    refine [inclusion: (0..100)]
    refine &(&1 < 5)
  end

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    refute Exchema.is?(:a, Type)
    refute Exchema.is?(11, Type)
    refute Exchema.is?(-3, Type)
    assert Exchema.is?(3, Type)
  end
end
