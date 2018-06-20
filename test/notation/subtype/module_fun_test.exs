defmodule Notation.Subtype.ModuleFunTest do
  use ExUnit.Case

  defmodule Type do
    import Exchema.Notation
    alias Exchema.Types, as: T
    subtype T.Integer, &(&1 < 5)
  end

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
    refute Exchema.is?(10, Type)
  end
end
