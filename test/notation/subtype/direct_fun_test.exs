defmodule Notation.Subtype.DirectFunTest do
  use ExUnit.Case
  import Exchema.Notation
  alias Exchema.Types, as: T

  subtype Type, T.Integer, &(&1 < 5)

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
    refute Exchema.is?(10, Type)
  end
end
