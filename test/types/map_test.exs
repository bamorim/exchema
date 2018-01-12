defmodule Exchema.Types.MapTest do
  use ExUnit.Case

  alias Exchema.Types, as: T

  test "it allows only maps" do
    a %{}
    a %{1 => 2}
    r nil
    r ""
    r 1
  end

  test "it can check the element type" do
    a %{1 => 2}
    a %{1 => 2, 3 => 4}
    r %{1 => "1"}
    r %{"1" => 1}
    r %{"1" => "1"}
  end

  test "allow map without inner type" do
    assert Exchema.is?(%{"1" => :a}, T.Map)
  end

  def a(val) do
    assert Exchema.is?(val, {T.Map, {T.Integer, T.Integer}})
  end
  def r(val) do
    refute Exchema.is?(val, {T.Map, {T.Integer, T.Integer}})
  end
end
