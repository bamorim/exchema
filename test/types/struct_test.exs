defmodule Exchema.Types.StructTest do
  use ExUnit.Case
  alias Exchema.Types, as: T
  defmodule Struct do
    defstruct [a: nil]
  end

  test "it allows only Struct with the right values" do
    r nil
    r ""
    r 1
    r %{}
  end

  test "it can check the element type" do
    a %Struct{a: 1}
    r %Struct{a: nil}
  end

  def a(val) do
    assert Exchema.is?(val, {T.Struct, {Struct, [a: T.Integer]}})
  end
  def r(val) do
    refute Exchema.is?(val, {T.Struct, {Struct, [a: T.Integer]}})
  end
end
