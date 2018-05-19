defmodule Notation.Newtype.DirectModAccessTest do
  use ExUnit.Case

  import Exchema.Notation
  newtype Type, Exchema.Types.Integer do
    def foo, do: :foo
  end

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
  end


  test "it executes in the module context" do
    assert :foo = Type.foo
  end
end
