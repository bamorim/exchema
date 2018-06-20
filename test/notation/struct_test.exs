defmodule Notation.StructTest do
  use ExUnit.Case

  defmodule Struct do
    import Exchema.Notation
    structure [
      foo: Exchema.Types.Integer.Negative,
      bar: Exchema.Types.Integer.Positive
    ]
  end

  test "it generates a struct" do
    assert :erlang.function_exported(Struct, :__struct__, 1)
  end

  test "it have all the fields" do
    s = %Struct{}
    assert Map.has_key?(s, :foo)
    assert Map.has_key?(s, :bar)
  end

  test "it generates an exchema type" do
    assert :erlang.function_exported(Struct, :__type__, 1)
  end

  test "it tests all the fields" do
    valid = %Struct{foo: -1, bar: 1}
    invalid = %Struct{foo: 1, bar: -1}
    assert Exchema.is?(valid, Struct)
    refute Exchema.is?(invalid, Struct)
  end
end
