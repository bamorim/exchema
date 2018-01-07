defmodule ExchemaTest do
  use ExUnit.Case
  doctest Exchema

  @basic_schema %{ field: [type: :integer] }

  test "it fetches fields from schema" do
    map = %{ field: "1" }

    assert %{field: 1} = Exchema.parse(map, @basic_schema)
  end

  test "it allows stringy keys transformations" do
    map = %{ "field" => "1" }

    assert %{field: 1} = Exchema.parse(map, @basic_schema)
  end

  test "it can fail" do
    map = %{ field: "not_integer" }

    assert {:errors, [{[:field], _err}]} = Exchema.parse(map, @basic_schema)
  end

  test "it allows nested structs" do
    schema = %{ nested: @basic_schema }
    map = %{ nested: %{ field: "1" }}

    assert %{ nested: %{ field: 1 } } = Exchema.parse(map, schema)
  end

  test "nested errors are flattened" do
    schema = %{ nested: @basic_schema }
    map = %{ nested: %{ field: "not_integer" }}

    assert {:errors, [{[:nested, :field], _err}]} = Exchema.parse(map, schema)
  end

  test "deep nesting errors" do
    schema = %{ nested: %{ nested: %{ nested: %{ nested: @basic_schema } } } }
    map = %{ nested: %{ nested: %{ nested: %{ nested: %{ field: "not_integer" } } } } }

    path = [:nested, :nested, :nested, :nested, :field]
    assert {:errors, [{^path, _}]} = Exchema.parse(map, schema)
  end

  test "integer transformer allow nil" do
    schema = @basic_schema
    map = %{ field: nil }

    assert %{ field: nil } == Exchema.parse(map, schema)
  end
end
