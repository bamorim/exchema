defmodule ExchemaDSLTest do
  use ExUnit.Case

  @moduletag :dsl

  test "dsl defines __exchema__" do
    assert %{ field: [type: :integer] } = SampleSchema.__exchema__()
  end

  test "sample schema" do
    map = %{ field: "1" }

    assert %{ field: 1 } = Exchema.parse(map, SampleSchema)
  end

  @tag :nested
  test "nested schema" do
    map = %{ nested: %{ field: "1" } }

    assert %{ nested: %{ field: 1 } } = Exchema.parse(map, NestedSchema)
  end
end
