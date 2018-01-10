defmodule Exchema.Types.ListTest do
  use ExUnit.Case

  alias Exchema.Types, as: T

  test "it allows only lists" do
    a []
    a [1]
    a [1,2]
    r nil
    r ""
    r 1
  end

  test "it can check the element type" do
    a [1]
    a []
    r ["1"]
  end

  def a(val) do
    assert Exchema.is?(val, {T.List, T.Integer})
  end
  def r(val) do
    refute Exchema.is?(val, {T.List, T.Integer})
  end
end
