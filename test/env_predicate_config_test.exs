defmodule EnvPredicateConfigTest do
  use ExUnit.Case, async: false

  setup do
    Application.put_env(:exchema, :predicates, [Predicates.Overrides, Predicates])
    on_exit fn ->
      Application.put_env(:exchema, :predicates, [])
    end
  end

  test "we can pass predicates by config" do
    type1 = {:ref, :any, is: :integer}
    type2 = {:ref, :any, is_integer: nil}
    assert [{_, _, :custom_error}] = Exchema.errors("1", type1)
    assert [{_, _, :not_an_integer}] = Exchema.errors("1", type2)
  end

  test "predicate library passed as params are matched first" do
    type = {:ref, :any, is: :integer}
    assert [{_, _, :custom_error_2}] = Exchema.errors("1", type, predicates: [Predicates.Overrides2])
  end
end
