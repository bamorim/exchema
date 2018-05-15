defmodule Exchema.Predicates do
  @moduledoc """
  Exschema default predicates library
  """

  @type error :: {:error, any}
  @type failure :: false | error | [error, ...]
  @type success :: :ok | true | []
  @type result :: failure | success

  @doc """
  Just applies the function as if it was a predicate.
  It also checks for exceptions to allow simpler functions.

  ## Examples

      iex> Exchema.Predicates.fun(1, &is_integer/1)
      true

      iex> Exchema.Predicates.fun("1", &is_integer/1)
      false

      iex> Exchema.Predicates.fun(1, &(&1 > 0))
      true

      iex> Exchema.Predicates.fun(0, &(&1 > 0))
      false

      iex> Exchema.Predicates.fun(1, fn _ -> {:error, :custom_error} end)
      {:error, :custom_error}

      iex> Exchema.Predicates.fun(1, fn _ -> raise RuntimeError end)
      {:error, :thrown}

  """
  @spec fun(any, ((any) -> result)) :: result
  def fun(val, fun) do
    fun.(val)
  rescue
    _ -> {:error, :thrown}
  end

  @doc """
  Checks wheter a value is a list.
  It can also check the types of the elemsts of the list by
  passing the `:element_type` param.

  ## Examples

      iex> Exchema.Predicates.list("", [])
      {:error, :not_a_list}

      iex> Exchema.Predicates.list([], [])
      :ok

      iex> Exchema.Predicates.list(["",1,""], element_type: Exchema.Types.Integer)
      {:error, {
        :nested_errors,
        [
          {0, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]},
          {2, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}
        ]}
      }

      iex> Exchema.Predicates.list([1,2,3], element_type: Exchema.Types.Integer)
      :ok

  """
  def list(list, _) when not is_list(list) do
    {:error, :not_a_list}
  end
  def list(list, opts) do
    case Keyword.get(opts, :element_type) do
      nil ->
        :ok
      type ->
        list
        |> Enum.with_index
        |> Enum.map(fn {e, idx} -> {idx, Exchema.errors(e, type)} end)
        |> Enum.filter(fn {_, err} -> length(err) > 0 end)
        |> nested_errors
    end
  end

  defp nested_errors(errors, error_key \\ :nested_errors)
  defp nested_errors([], _), do: :ok
  defp nested_errors(errors, error_key) do
    {:error, {error_key, errors}}
  end

  @doc """
  Checks whether or not the given value is a struct or a specific struct.

  Note: It's named `is_struct` to avoid conflict with `Kernel.struct`.

  ## Examples

      iex> Exchema.Predicates.is_struct(%{}, [])
      {:error, :not_a_struct}

      iex> Exchema.Predicates.is_struct(nil, [])
      {:error, :not_a_struct}

  Also, keep in mind that many internal types are actually structs

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, nil)
      :ok

      iex> Exchema.Predicates.is_struct(NaiveDateTime.utc_now, nil)
      :ok

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, DateTime)
      :ok

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, NaiveDateTime)
      {:error, :invalid_struct}

      iex> Exchema.Predicates.is_struct(NaiveDateTime.utc_now, DateTime)
      {:error, :invalid_struct}

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, [NaiveDateTime, DateTime])
      :ok

      iex> Exchema.Predicates.is_struct(Date.utc_today, [NaiveDateTime, DateTime])
      {:error, :invalid_struct}

  """
  def is_struct(%{__struct__: real}, expected), do: check_struct(real, expected)
  def is_struct(_, _), do: {:error, :not_a_struct}

  defp check_struct(real, expected) when expected == real, do: :ok
  defp check_struct(_, expected) when expected in [nil, :any], do: :ok
  defp check_struct(real, alloweds) when is_list(alloweds) do
    if real in alloweds, do: :ok, else: {:error, :invalid_struct}
  end
  defp check_struct(_,_), do: {:error, :invalid_struct}

  @doc """
  Checks a map for its key types, value types or specific value types (for a given key).

  ## Examples

      iex> Exchema.Predicates.map("", [])
      {:error, :not_a_map}

      iex> Exchema.Predicates.map(%{}, [])
      :ok

      iex > Exchema.Predicates.map(%{1 => "value"}, [key: Exchema.Types.Integer])
      :ok

      iex > Exchema.Predicates.map(%{"key" => 1}, [values: Exchema.Types.Integer])
      :ok

      iex > Exchema.Predicates.map(%{"key" => 1}, [keys: Exchema.Types.Integer])
      {:error, {
        :key_errors,
        [{"key", [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}

      iex > Exchema.Predicates.map(%{1 => "value"}, [values: Exchema.Types.Integer])
      {:error, {
        :value_errors,
        [{"value", [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}

      iex> Exchema.Predicates.map(%{foo: :bar}, fields: [foo: Exchema.Types.Integer])
      {:error, {
        :nested_errors,
        [{:foo, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}
  """
  defdelegate map(input, opts), to: Exchema.Predicates.Map

  @doc """
  Checks against system guards like `is_integer` or `is_float`.

  ## Examples

      iex> Exchema.Predicates.is(1, :integer)
      :ok

      iex> Exchema.Predicates.is(1.0, :float)
      :ok

      iex> Exchema.Predicates.is(1, :nil)
      {:error, :not_nil}

      iex> Exchema.Predicates.is(1, :atom)
      {:error, :not_an_atom}

      iex> Exchema.Predicates.is(nil, :binary)
      {:error, :not_a_binary}

      iex> Exchema.Predicates.is(nil, :bitstring)
      {:error, :not_a_bitstring}

      iex> Exchema.Predicates.is(nil, :boolean)
      {:error, :not_a_boolean}

      iex> Exchema.Predicates.is(nil, :float)
      {:error, :not_a_float}

      iex> Exchema.Predicates.is(nil, :function)
      {:error, :not_a_function}

      iex> Exchema.Predicates.is(nil, :integer)
      {:error, :not_an_integer}

      iex> Exchema.Predicates.is(nil, :list)
      {:error, :not_a_list}

      iex> Exchema.Predicates.is(nil, :map)
      {:error, :not_a_map}

      iex> Exchema.Predicates.is(nil, :number)
      {:error, :not_a_number}

      iex> Exchema.Predicates.is(nil, :pid)
      {:error, :not_a_pid}

      iex> Exchema.Predicates.is(nil, :port)
      {:error, :not_a_port}

      iex> Exchema.Predicates.is(nil, :reference)
      {:error, :not_a_reference}

      iex> Exchema.Predicates.is(nil, :tuple)
      {:error, :not_a_tuple}

  """
  # Explicit nil case becasue Kernel.is_nil is a macro
  def is(nil, nil), do: :ok
  def is(_, nil), do: {:error, :not_nil}
  def is(val, key) do
    if apply(Kernel, :"is_#{key}", [val]) do
      :ok
    else
      {:error, is_error_msg(key)}
    end
  end

  defp is_error_msg(:atom), do: :not_an_atom
  defp is_error_msg(:integer), do: :not_an_integer
  defp is_error_msg(key), do: :"not_a_#{key}"

  @doc """
  Ensure the value is in a list of values

  ## Examples

      iex> Exchema.Predicates.inclusion("apple", ["apple", "banana"])
      :ok

      iex> Exchema.Predicates.inclusion(5, 1..10)
      :ok

      iex> Exchema.Predicates.inclusion("horse", ["apple", "banana"])
      {:error, :invalid}

  """
  def inclusion(val, values) do
    if val in values, do: :ok, else: {:error, :invalid}
  end

  @doc """
  Ensure the value is not in a list of values

  ## Examples

      iex> Exchema.Predicates.exclusion("apple", ["apple", "banana"])
      {:error, :invalid}

      iex> Exchema.Predicates.exclusion(5, 1..10)
      {:error, :invalid}

      iex> Exchema.Predicates.exclusion("horse", ["apple", "banana"])
      :ok

  """
  def exclusion(val, values) do
    if val in values, do: {:error, :invalid}, else: :ok
  end

  @doc """
  Checks against a specific regex format

  ## Examples

      iex> Exchema.Predicates.format("starts-with", ~r/^starts-/)
      :ok

      iex> Exchema.Predicates.format("does-not-starts-with", ~r/^starts-/)
      {:error, :invalid}
  """
  def format(val, regex) when is_binary(val) do
    if Regex.match?(regex, val), do: :ok, else: {:error, :invalid}
  end
  def format(_, _), do: {:error, :invalid}

  @doc """
  Checks the length of the input. You can pass a max, a min, a range or a specific lenght.

  Can check length of either lists, strings or tuples.

  ## Examples

      iex> Exchema.Predicates.length("123", 3)
      :ok

      iex> Exchema.Predicates.length([1,2,3], 3)
      :ok

      iex> Exchema.Predicates.length({1,2,3}, 3)
      :ok

      iex> Exchema.Predicates.length([1,2,3], min: 2)
      :ok

      iex> Exchema.Predicates.length([1,2,3], max: 3)
      :ok

      iex> Exchema.Predicates.length([1,2,3], 2..4)
      :ok

      iex> Exchema.Predicates.length([1,2,3], min: 2, max: 4)
      :ok

      iex> Exchema.Predicates.length([1,2,3], min: 4)
      {:error, :invalid_length}

      iex> Exchema.Predicates.length([1,2,3], max: 2)
      {:error, :invalid_length}

      iex> Exchema.Predicates.length([1,2,3], min: 1, max: 2)
      {:error, :invalid_length}

      iex> Exchema.Predicates.length([1,2,3], 2)
      {:error, :invalid_length}

      iex> Exchema.Predicates.length([1,2,3], 1..2)
      {:error, :invalid_length}

  """
  def length(val, opts) when is_binary(val) do
    compare_length(String.length(val), length_bounds(opts))
  end
  def length(val, opts) when is_tuple(val) do
    compare_length(val |> Tuple.to_list |> length, length_bounds(opts))
  end
  def length(val, opts) when is_list(val) do
    compare_length(length(val), length_bounds(opts))
  end
  def length(_, _), do: {:error, :invalid}

  defp length_bounds(n) when is_integer(n), do: {n, n}
  defp length_bounds(%{__struct__: Range, first: min, last: max}), do: {min, max}
  defp length_bounds(opts) when is_list(opts) do
    {Keyword.get(opts, :min), Keyword.get(opts, :max)}
  end
  defp length_bounds(_), do: {nil, nil}

  defp compare_length(_, {nil, nil}), do: :ok
  defp compare_length(l, {min, nil}) do
    if min > l, do: {:error, :invalid_length}, else: :ok
  end
  defp compare_length(l, {nil, max}) do
    if max < l, do: {:error, :invalid_length}, else: :ok
  end
  defp compare_length(l, {min, max}) when min > l or max < l, do: {:error, :invalid_length}
  defp compare_length(_, _), do: :ok

  @doc """
  Checks if something is greater than a value

  iex> Exchema.Predicates.gt(2, 1)
  :ok

  iex> Exchema.Predicates.gt(2, 2)
  {:error, :not_greater}

  iex> Exchema.Predicates.gt(2, 3)
  {:error, :not_greater}

  iex> Exchema.Predicates.gt("b", "a")
  :ok

  iex> Exchema.Predicates.gt("a", "b")
  {:error, :not_greater}
  """
  def gt(a, b) when a > b, do: :ok
  def gt(_, _), do: {:error, :not_greater}

  @doc """
  Checks if something is greater than or equal to a value

  iex> Exchema.Predicates.gte(2, 1)
  :ok

  iex> Exchema.Predicates.gte(2, 2)
  :ok

  iex> Exchema.Predicates.gte(2, 3)
  {:error, :not_greater_or_equal}

  iex> Exchema.Predicates.gte("b", "a")
  :ok

  iex> Exchema.Predicates.gte("a", "b")
  {:error, :not_greater_or_equal}
  """
  def gte(a, b) when a >= b, do: :ok
  def gte(_, _), do: {:error, :not_greater_or_equal}

  @doc """
  Checks if something is lesser than a value

  iex> Exchema.Predicates.lt(1, 2)
  :ok

  iex> Exchema.Predicates.lt(2, 2)
  {:error, :not_lesser}

  iex> Exchema.Predicates.lt(3, 2)
  {:error, :not_lesser}

  iex> Exchema.Predicates.lt("a", "b")
  :ok

  iex> Exchema.Predicates.lt("b", "a")
  {:error, :not_lesser}
  """
  def lt(a, b) when a < b, do: :ok
  def lt(_, _), do: {:error, :not_lesser}

  @doc """
  Checks if something is lesser than or equal a value

  iex> Exchema.Predicates.lte(1, 2)
  :ok

  iex> Exchema.Predicates.lte(2, 2)
  :ok

  iex> Exchema.Predicates.lte(3, 2)
  {:error, :not_lesser_or_equal}

  iex> Exchema.Predicates.lte("a", "b")
  :ok

  iex> Exchema.Predicates.lte("b", "a")
  {:error, :not_lesser_or_equal}
  """
  def lte(a, b) when a <= b, do: :ok
  def lte(_, _), do: {:error, :not_lesser_or_equal}
end
