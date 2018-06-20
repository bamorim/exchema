defmodule Exchema.Types.OneStructOfTest do
  use ExUnit.Case
  
  alias Exchema.Types, as: T

  defmodule Structs do
    import Exchema.Notation
    structure A, a: T.Integer
    structure B, a: T.Float
    structure Other, a: T.Integer
  end

  @extype {T.OneStructOf, [Structs.A, Structs.B]}

  test "it allows all the specified types" do
    assert Exchema.is?(%Structs.A{a: 1}, @extype)
    assert Exchema.is?(%Structs.B{a: 1.0}, @extype)
    refute Exchema.is?(1, @extype)
    refute Exchema.is?(%Structs.A{a: 1.0}, @extype)
    refute Exchema.is?(%Structs.B{a: 1}, @extype)
  end

  test "it returns a simple error when the type is not a struct" do
    assert [{_, _, :invalid_struct}] = Exchema.errors(1.0, @extype)
  end

  test "it returns a simple error when the type is not any of the given structs" do
    value = %Structs.Other{a: 1}
    assert [{_, _, :invalid_struct}] = Exchema.errors(value, @extype)
  end

  test "it returns the specific errors of the type" do
    value = %Structs.A{a: "1"}
    [{_,_,errors}] = Exchema.errors(value, Structs.A)
    assert [{ _, _, ^errors }] = Exchema.errors(value, @extype)
  end
end