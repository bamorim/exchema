# Exchema

Exchema is a library to define, validate and coerce data. It allows
you to check the type for a given value at runtime (it is not static
type checking).

It uses the idea of **refinement types**, in which we have a global type
(which all values belong) and can refine that type with the use of
**predicates**.

It also comes with a neat DSL to help you define your types.

```elixir
import Exchema.Notation
newtype Name, Exchema.Types.String
subtype Country, Exchema.Types.Atom, [inclusion: ~w{brazil canada portugal}a]
type Metadata, &(is_list(&1) || is_map(&1))
structure FullName, [first: Name, last: Name]

defmodule MyStructure do
  structure [
    name: FullName,
    country: Country,
    metadata: Metadata
  ]
end

valid = %MyStructure{
  name: %FullName{
    first: "Bernardo",
    last: "Amorim"
  },
  country: :brazil,
  metadata: %{any: :thing}
}

invalid = %MyStructure{
  name: %FullName{
    first: 1234,
    last: :not_a_string
  },
  country: :croatia,
  metadata: :not_a_list_nor_a_map
}

Exchema.is?(valid, MyStructure)
# => true

Exchema.is?(invalid, MyStructure)
# => false

Exchema.errors(invalid, MyStructure)
# => [{{Exchema.Predicates, :map},[fields: [...]],{:nested_errors, ...]

invalid |> Exchema.errors(MyStructure) |> Exchema.Error.flattened
# => [
#  {[:name, :first], {Exchema.Predicates, :is}, :binary, :not_a_binary},
#  {[:name, :last], {Exchema.Predicates, :is}, :binary, :not_a_binary},
#  {[:country], {Exchema.Predicates, :inclusion}, [:brazil, :canada, :portugal],
#   :invalid},
#  {[:metadata], {Exchema.Predicates, :fun},
#   #Function<0.33830354/1 in :elixir_compiler_0.__MODULE__/1>, :invalid}
# ]
```

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
`{Exchema.Types.Map, {Exchema.Types.String, Exchema.Types.Integer}}` repre"/auth/auth0"sents
a map from strings to integer.

Types with 0 params can be represented just by the module name.
Types with 1 param can be represented by a tuple `{type, argument}`
Types with N params can be represented by a tuple `{type, arguments}` where
arguments is a tuple with N elements.

```elixir
iex> Exchema.is?([1,2,3], {Exchema.Types.List, Exchema.Types.Integer})
true

iex> Exchema.is?([1, "2", 3], {Exchema.Types.List, Exchema.Types.Integer})
false

iex> Exchema.is?(%{a: 1}, {Exchema.Types.Map, {Exchema.Types.Atom, Exchema.Types.Integer}})
true
```

## Defining your own types

When defining types we need to understand `subtype` and `structure` and `refine`.

### Subtype

It defines a subtype given the original type and a list of refinements.

```elixir
defmodule ShortString do
  import Exchema.Notation
  subtype Exchema.Types.String, []
end
```

## About Types

A type can be:

- the global type `:any`
- a type reference such as `Exchema.Types.String`
- a type refinement such as `{:ref, :any, length: 1}` (more on that later)
- a type application (for parametric types) such as `{Exchema.Types.List, Exchema.Types.String}`

## Coercion

This should probably move to another library, but for now it is bundled here.

`Exchema.Coercion` can receive some input and coerce to a specific type.

```elixir
iex> Exchema.Coercion.coerce("2018-01-01", Exchema.Types.Date)
~D[2018-01-01]

defmodule MyStruct do
  use Exchema.Struct, fields: [
    foo: Exchema.Types.Integer,
    bar: Exchema.Types.Date
  ]
end

iex> Exchema.Coercion.coerce(%{"foo" => 1, "bar" => "2018-01-01"}, MyStruct)
%MyStruct{
  foo: 1,
  bar: ~D[2018-01-01]
}

iex> Exchema.Coercion.coerce(["1", 2, 3.0], {Exchema.Types.List, Exchema.Types.Integer})
[1,2,3]
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
