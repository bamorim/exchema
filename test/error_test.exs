defmodule Exchema.ErrorTest do
  use ExUnit.Case

  test "we can generate a flattened test report" do
    err = {{Predicate, :pred}, nil, :some_error}
    nest = fn errs -> {{Predicate, :pred}, nil, {:nested_errors, errs}} end
    nested_error = nest.([
      {
        :addresses,
        [
          nest.([
            {
              0,
              [
                nest.([
                  {:city,[err]}
                ])
              ]
            }
          ])
        ]
      },
      {
        :name,
        [err]
      }
    ])
    root_error = err
    errors = [nested_error, root_error]
    flattened_errors = errors |> Exchema.flatten_errors

    assert [
      {[:addresses, 0, :city], _, _, :some_error},
      {[:name], _, _, :some_error},
      {[], _, _, :some_error}
    ] = flattened_errors
  end
end
