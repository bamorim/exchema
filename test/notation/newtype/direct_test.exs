defmodule Notation.Newtype.DirectTest do
  use ExUnit.Case
  import Exchema.Notation

  newtype Type, Exchema.Types.Integer

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
  end
end
