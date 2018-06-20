defmodule Exchema.Types.OneOfTest do
  use ExUnit.Case
  
  alias Exchema.Types, as: T

  @extype {T.OneOf, [T.Integer, T.String, T.Date]}

  test "it allows all the specified types" do
    assert Exchema.is?(1, @extype)
    assert Exchema.is?("s", @extype)
    assert Exchema.is?(Date.utc_today, @extype)
    refute Exchema.is?(1.0, @extype)
    refute Exchema.is?(DateTime.utc_now, @extype)
  end

  test "it returns a simple error" do
    assert [{_, _, :invalid_type}] = Exchema.errors(1.0, @extype)
  end
end