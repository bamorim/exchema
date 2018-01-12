defmodule StructTest do
  use ExUnit.Case

  @moduletag :struct

  defmodule Struct do
    use Exchema.Struct, fields: [
      foo: Exchema.Types.Integer,
      bar: {Exchema.Types.List, Exchema.Types.Integer}
    ], check_schema: [
      fun: fn schema ->
        Enum.all?(schema.bar, &(&1 >= schema.foo))
      end
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

  test "it generates a type" do
    assert :erlang.function_exported(Struct, :__type__, 1)
  end

  test "type tests for inner types" do
    valid = %Struct{foo: 1, bar: [1]}
    invalid = %Struct{foo: "1", bar: "[1]"}
    assert Exchema.is?(valid, Struct)
    refute Exchema.is?(invalid, Struct)
  end

  test "type tests for schema" do
    refute Exchema.is?(%Struct{foo: 1, bar: [1, 0]}, Struct)
  end
end
