defmodule Exchema.ErrorTest do
  use ExUnit.Case

  defmodule StreetAddress do
    alias Exchema.Types, as: T
    use Exchema.Struct, fields: [
      name: T.String,
      number: T.Integer
    ]
  end

  defmodule Address do
    alias Exchema.Types, as: T
    use Exchema.Struct, fields: [
      country: T.String,
      state: {:ref, T.String, length: 2},
      street_address: StreetAddress
    ]
  end

  defmodule User do
    alias Exchema.Types, as: T
    use Exchema.Struct, fields: [
      password: T.String,
      password_confirmation: T.String,
      addresses: {T.List, Address},
    ], check_schema: [
      fun: fn u ->
        if u.password == u.password_confirmation do
          true
        else
          {:error, :password_confirmation}
        end
      end
    ]
  end

  test "we can generate a flattened test report" do
    schema = %User{
      password: "1234",
      password_confirmation: "123",
      addresses: [%Address{
        country: "Brazil",
        state: "RJ",
        street_address: %StreetAddress{
          name: nil,
          number: 10
        }
      }]
    }
    errors = schema |> Exchema.errors(User) |> Exchema.Error.flattened
    assert [{[:addresses, 0, :street_address, :name], _, _, _}, {[], _, _, :password_confirmation}] = errors
  end
end
