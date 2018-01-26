# Exchema

Exchema is a library to define, validate and coerce data. It allows
you to check the type for a given value at runtime (it is not static
type checking).

It uses the idea of **refinement types**, in which we have a global type
(which all values belong) and can refine that type with the use of
**predicates**.

## Types

A type can be:

- the global type `:any`
- a type reference such as `Exchema.Types.String`
- a type refinement such as `{:ref, :any, length: 1}`
- a type application (for parametric types) such as `{Exchema.Types.List, Exchema.Types.String}`

## Checking types

Exchema ships with some predefined types that you can check using
`Exchema.is?/2`

```elixir
iex> Exchema.is?("1234", Exchema.Types.String)
true

iex> Exchema.is?(1234, Exchema.Types.String)
false

iex> Exchema.is?(1234, Exchema.Types.Integer)
true
```

There is also the global type `:any`

```elixir
iex> Exchema.is?("1234", :any)
true

iex> Exchema.is?(1234, :any)
true
```

## Parametric types

A type can be specialized, e.g. lists can have an inner type specified, so
`{Exchema.Types.List, Exchema.Types.Integer}` represents a list of integers.

In the case of list, you can just use and not specify it directly, so
`Exchema.Types.List` is a list of elements of any type, or
`{Exchema.Types.List, :any}`.

Some types can have multiple parameters, e.g. a map.
`{Exchema.Types.Map, {Exchema.Types.String, Exchema.Types.Integer}}` represents
a map from strings to integer.

Types with 0 params can be represented just by the module name.
Types with 1 param can be represented by a tuple `{type, argument}`
Types with N params can be represented by a tuple `{type, arguments}` where
arguments is a tuple with N elements.

## Type refinement

This is the core of our system, it allows to create more specialized types starting
from the global type `:any`. In fact, all the types that ships with Exchema are
just refinements from other types. (You will see it more in defining your own types)

A refined type is a 3-tuple with the `:ref` keyword, the source type and a list of
2-tuples containing the predicate reference and the predicate argument

A predicate is basically a reference to a function and one argument.

```elixir
#           source type==||       ||==predicate reference
#                        ||       ||
#     ref keyword==||    ||       ||  ||==predicate argument
#                  \/    \/       \/  \/
iex> Exchema.is?({:ref, :any, length: 1 }, [])
false

iex> Exchema.is?({:ref, :any, length: 1}, ["element"])
true
```

## Predicate

A predicate in the end is just a function with 2 arguments, the first being the value
to check and the second is an arbitrary argument. It should return either
`true` or `:ok` to represent a valid value and `false`, `{:error, error}` or
`[{:error, error}]` to represent an invalid value.

## Predicate References

Here `:length` is the reference to a function (which comes from a predicate library).

By default, Exchema ships with a predicate library which you can check at `Exchema.Predicates`
and that module exposes some functions, e.g. `length/2`.

You can also reference a function directly in the form of `{module, function_name}`, so actually
`:length` is the same as `{Exchema.Predicates, :length}` (expect if you override the default lib).

## Defining your own type

In the type refinement section you "already defined" a new type, but you didn't give it a name.

When refining `:any` with `length: 1` predicate you created a new type.

To be able to reference it by name, you need to define a module.

A type reference is just a module that defines a function `___type__/1`.

That function will receive as the argument a tuple with the arguments passed when referencing
the type.

If you want to define a type without params, you can do it by defining a module like

```elixir
defmodule MyType do
  # we can ignore the argument because it is not a parametric type
  def __type__(_) do
    {:ref, :any, length: 1}
  end
end
```

What happens is that when the type is trying to check against a type `MyType`, it will
call `MyType.__type__({})` and see the response. This is the type resolving procedure.

Notice that an empty tuple is passed (this is because you referenced it as `MyType`),
with that being said `Exchema.is?(val, MyType)` is the same as `Exchema.is?(val, {MyType, {}})`.

If you want to define a parametric type you can just accept a tuple with size 1 (or more if you want)

```elixir
defmodule MyType do
  # Here we are defining a type that can receive 1 or 0 params.
  # If no params are given, it is a type with length 1, otherwise it has an arbitrary length.
  def __type__({}), do: __type__({0})
  def __type__({length}) do
    {:ref, :any, length: length}
  end
end
```

Now you can use that type as `{MyType, 10}` or `{MyType, {10}}`, which are equivalent.

## Struct Types

A lot of data types in elixir are just structs. That's why we have an special type (and predicates)
to treat structs.

Let's say we want to represent a geographic location, a coordinate. We can use the type `Exchema.Types.Struct`.

This type receives two arguments, a module (the struct module) and a list of field types, which is a list
of tuples containing the key and the expected type, e.g. `{:long, Exchema.Types.Float}`. But you can use
elixir syntax sugar to make it prettier, like the example below.

```elixir
defmodule Coord do
  defstruct [:long, :lat]
  
  def __type__(_) do
    {Exchema.Types.Struct, {__MODULE__, [
      long: Exchema.Types.Number,
      lat: Exchema.Types.Number
    ]}}
  end
end

iex> Exchema.is?(%{}, Coord)
false

iex> Exchema.is?(%Coord{long: "", lat: ""}, Coord)
false

iex> Exchema.is?(%Coord{long: 10.0, lat: 10.0}, Coord)
true
```

## Exchema.Struct

However, defining struct types can be really cumbersome and thats why we have
the `Exchema.Struct` module which you can use as

```elixir
defmodule Coord do
  use Exchema.Struct, fields: [
    long: Exchema.Types.Number,
    lat: Exchema.Types.Number
  ]
end
```

And you can alias `Exchema.Types` to have smaller type definitions.

```elixir
defmodule Coord do
  alias Exchema.Types, as: T

  use Exchema.Struct, fields: [
    long: T.Number,
    lat: T.Number
  ]
end
```

## Defining your own predicate

Defining a predicate is as simple as defining a function.

Let's say we want to use `uuid` lib to validate wheter or not a string
is a UUID.

```elixir 
defmodule MyPredicates do
  def uuid(value, _) when is_binary(value) do
    case UUID.info(value) do
      :ok ->
        :ok
      _ ->
        {:error, :not_a_valid_uuid}
    end
  end
  def uuid(_, _), do: {:error, :not_a_valid_uuid}
end
```

Now we can use that in our types

```elixir
defmodule MyUUID do
  def __type__(_) do
    {:ref, Exchema.Types.String, [
      {{MyPredicates, :uuid}, true}
    ]}
  end
end
```

## Configuring your predicate library

You can configure Exchema to include your predicate library by adding
```elixir
config :exchema,
  predicates: [MyPredicates]
```

Now you can use the function name directly, so you can rewrite your type to
be:

```elixir
defmodule MyUUID do
  def __type__(_) do
    {:ref, Exchema.Types.String, uuid: true}
  end
end
```

And then you can check the uuid

```elixir
iex> Exchema.is?("randomstring", MyUUID)
false

iex> Exchema.is?("f4fd18af-1e8d-4262-a655-c1fa83ae9162", MyUUID)
true
```

## Installation

Add `exchema` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exchema, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exchema](https://hexdocs.pm/exchema).
