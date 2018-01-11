defmodule CoercionTest do
  use ExUnit.Case

  @moduletag :coercion

  import Exchema.Coercion

  defmodule MyAny do
    def __type__({}) do
      {:ref, :any, []}
    end
  end

  defmodule CustomCoercion do
    def __type__({}) do
      {:ref, :any, []}
    end

    defmodule ExchemaCoercion do
      def coerce(input) do
        input <> input
      end
    end
  end

  defmodule MacroCoercion do
    def __type__({}) do
      {:ref, :any, []}
    end

    use Exchema.Coercion, fn (input) ->
      input <> input <> input
    end
  end

  defmodule OutsideCoercion do
    def __type__({}) do
      {:ref, :any, []}
    end
  end

  require Exchema.Coercion
  Exchema.Coercion.defcoercion OutsideCoercion, fn (input) ->
    input <> "3"
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

  test "we can use Exchema.Coercion to define a coercion" do
    assert "121212" = coerce("12", MacroCoercion)
  end

  test "we can define a coercion outside the module" do
    assert "123" = coerce("12", OutsideCoercion)
  end
end
