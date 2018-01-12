defmodule Types.OptionalTest do
  use ExUnit.Case

  alias Exchema.Types, as: T
  import Exchema, only: [is?: 2, errors: 2]

  test "but can have a specific inner type" do
    refute is?("something", {T.Optional, T.Integer})
  end

  test "the error messages are propagated" do
    assert [{_, _, [{_, _, :not_an_integer}]}] = errors("1", {T.Optional, T.Integer})
  end

  test "but still can be nil even with specific inner type" do
    assert is?(nil, {T.Optional, T.Integer})
  end
end
