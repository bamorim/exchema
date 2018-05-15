defmodule Notation.Type.DirectModAccessTest do
  use ExUnit.Case
  import Exchema.Notation

  type Type1, [is: :integer] do
    def foo, do: :foo
  end

  type Type2, &is_integer/1 do
    def foo, do: :foo
  end

  test "it executes in the module context" do
    assert :foo = Type1.foo
    assert :foo = Type2.foo
  end
end
