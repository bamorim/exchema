defmodule Notation.Type.DirectFunTest do
  use ExUnit.Case
  import Exchema.Notation

  type Type, &is_integer/1

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
  end
end
