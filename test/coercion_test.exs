defmodule CoercionTest do
  use ExUnit.Case

  @moduletag :coercion

  import Exchema.Coercion
  alias Exchema.Types, as: T

  defmodule MyAny do
    def __type__({}) do
      {:ref, :any, []}
    end
  end

  defmodule CustomCoercion do
    def __type__({}) do
      {:ref, :any, []}
    end

    def __coerce__(input) do
      input <> input
    end
  end

  defmodule Struct do
    use Exchema.Struct, fields: [
      foo: T.Integer
    ]
  end

  defmodule Nested do
    use Exchema.Struct, fields: [
      child: {T.Optional, __MODULE__}
    ]
  end

  test "Coercion to any doesnt change anything" do
    assert "1234" = coerce("1234", :any)
  end

  test "Coercion to a type that it doesnt know how to coerce fall back to supertype" do
    assert "1234" = coerce("1234", MyAny)
  end

  test "we can define a specific coercion for type" do
    assert "1212" = coerce("12", CustomCoercion)
  end

  test "coercing ints" do
    assert 1 = coerce("1", T.Integer)
    assert 1 = coerce(1.4, T.Integer)
    assert 1 = coerce(0.9, T.Integer)
    assert "a" = coerce("a", T.Integer)
  end

  test "coercing floats" do
    assert 1.0 = coerce("1.0", T.Float)
    assert 1.0 = coerce(1.0, T.Float)
    assert "a" = coerce("a", T.Float)
  end

  test "coercing booleans" do
    assert coerce("true", T.Boolean)
    refute coerce("false", T.Boolean)
    assert "nothing" = coerce("nothing", T.Boolean)
  end

  test "coercing strings" do
    assert "1" = coerce(1, T.String)
    assert "true" = coerce(true, T.String)
  end

  test "coercing optionals" do
    assert is_nil(coerce(nil, {T.Optional, T.Integer}))
    assert 1 = coerce("1", {T.Optional, T.Integer})
  end

  test "there is a smart coercion for Exchema.Struct's" do
    assert %Struct{foo: 1} = coerce(%{"foo" => "1"}, Struct)
  end

  test "and it can be nested as far as we want" do
    input = %{"child" => %{"child" => %{"child" => nil}}}
    assert %Nested{child: %Nested{child: %Nested{child: nil}}} = coerce(input, Nested)
  end
end
