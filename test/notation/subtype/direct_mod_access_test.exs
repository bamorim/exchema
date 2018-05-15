defmodule Notation.Subtype.DirectModAccessTest do
  use ExUnit.Case
  import Exchema.Notation
  alias Exchema.Types, as: T

  subtype Type1, T.Integer, [inclusion: (1..10)] do
    def foo, do: :foo
  end

  subtype Type2, T.Integer, &(&1 > 2) do
    def foo, do: :foo
  end

  test "it executes in the module context" do
    assert :foo = Type1.foo
    assert :foo = Type2.foo
  end
end
