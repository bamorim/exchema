defmodule ExchemaDSLTest do
  use ExUnit.Case
  alias Schemas.{
    Simple,
    Nested,
    Struct
  }

  @moduletag :dsl

  test "dsl defines __exchema__" do
    assert %{ field: [type: :integer] } = Simple.__exchema__()
  end

  test "sample schema" do
    map = %{ field: "1" }

    assert %{ field: 1 } = Exchema.parse(map, Simple)
  end

  @tag :nested
  test "nested schema" do
    map = %{ nested: %{ field: "1" } }

    assert %{ nested: %{ field: 1 } } = Exchema.parse(map, Nested)
  end

  @tag :struct
  test "exchema can generate a struct" do
    assert :erlang.function_exported(Struct, :__struct__, 1)
  end

  @tag :struct
  test "generated struct contains all fields" do
    struct = %Struct{}
    assert Map.has_key?(struct, :field)
  end

  @tag :struct
  test "exchema doesn't generate struct by default" do
    refute :erlang.function_exported(Simple, :__struct__, 1)
  end
end
