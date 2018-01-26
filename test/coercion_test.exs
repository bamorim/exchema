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

  test "we can coerce date/time types from strings" do
    assert %{day: 1, month: 2, year: 2000} = coerce("2000-02-01", T.Date)
    assert %{hour: 22, minute: 11, second: 0} = coerce("22:11:00", T.Time)
    assert %{year: 2000, second: 30} = coerce("2000-01-01T00:00:30", T.NaiveDateTime)
    assert %{hour: 1} = coerce("2000-01-01T01:00:00Z", T.DateTime)
    assert %{hour: 2} = coerce("2000-01-01T01:00:00-01:00", T.DateTime)
  end

  test "we can coerce between date/time types" do
    naive = ~N[2000-01-01T12:00:00]
    assert %Date{year: 2000} = coerce(naive, T.Date)
    assert %Time{hour: 12} = coerce(naive, T.Time)
    assert %DateTime{year: 2000, zone_abbr: "UTC"} = coerce(naive, T.DateTime)

    {:ok, datetime} = DateTime.from_naive(naive, "Etc/UTC")
    assert %Date{year: 2000} = coerce(datetime, T.Date)
    assert %Time{hour: 12} = coerce(datetime, T.Time)
    assert %NaiveDateTime{year: 2000} = coerce(datetime, T.NaiveDateTime)

    date = ~D[2000-01-01]
    assert %DateTime{year: 2000, day: 01, zone_abbr: "UTC"} = coerce(date, T.DateTime)
    assert %NaiveDateTime{year: 2000, day: 01} = coerce(date, T.NaiveDateTime)
  end

  test "we can coerce tuples to list" do
    result = coerce({1,2,3}, T.List)
    assert [1,2,3] = result
  end

  test "we can coerce lists" do
    result = coerce(["1", 2, 3.1], {T.List, T.Integer})
    assert [1,2,3] = result
  end
end
