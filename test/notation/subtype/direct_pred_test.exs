defmodule Notation.Subtype.DirectPredTest do
  defmodule Notation.Type.DirectPredTest do
    use ExUnit.Case
    import Exchema.Notation
    alias Exchema.Types, as: T

    subtype Type, T.Integer, [inclusion: (1..10)]

    test "it generates an exchema type" do
      assert :erlang.function_exported(Type, :__type__, 1)
    end

    test "it executes the function to check the type" do
      assert Exchema.is?(1, Type)
      refute Exchema.is?(:a, Type)
      refute Exchema.is?(11, Type)
    end
  end
end
