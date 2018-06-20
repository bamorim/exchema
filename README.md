# Exchema

Exchema is a library to define, validate and coerce data. It allows
you to check the type for a given value at runtime (it is not static
type checking).

It uses the idea of **refinement types**, in which we have a global type
(which all values belong) and can refine that type with the use of
**predicates**.

Also, check [`exchema_coercion`](https://github/bamorim/exchema_coercion) and [`exchema_stream_data`](https://github.com/bamorim/exchema_stream_data)

It also comes with a neat DSL to help you define your types.

The macros you need to keep in mind are `subtype/2`, `structure/1` and `refine/1`

```elixir
import Exchema.Notation

defmodule Name, do: subtype(Exchema.Types.String, [])

defmodule Continent do
  subtype(Exchema.Types.Atom, [inclusion: ~w{europe north_america, south_america}a])
end

defmodule Country do
  subtype(Exchema.Types.Atom, [inclusion: ~w{brazil canada portugal}a])
  def continent_for(country) do
    case country do
      :brazil -> :south_america,
      :canada -> :north_america,
      _ -> :europe
    end
  end
end

defmodule Metadata, do: subtype(:any, [fun: &(is_list(&1) || is_map(&1))])

defmodule FullName, do: structure([first: Name, last: Name])

defmodule MyStructure do
  structure [
    name: FullName,
    country: Country,
    continent: Continent,
    metadata: Metadata
  ]
  
  refine([fun: fn %{country: country, continent: continent} ->
    Country.continent_for(country) == continent
  end])
  
  def valid do
    %MyStructure{
      name: %FullName{
        first: "Bernardo",
        last: "Amorim"
      },
      country: :brazil,
      continent: :south_america,
      metadata: %{any: :thing}
    }
  end
  
  def invalid do
    %MyStructure{
      name: %FullName{
        first: 1234,
        last: :not_a_string
      },
      country: :croatia,
      continent: :oceania,
      metadata: :not_a_list_nor_a_map
    }
  end
end

Exchema.is?(MyStructure.valid, MyStructure)
# => true

Exchema.is?(MyStructure.invalid, MyStructure)
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

## Simplifying

Sometimes typing `defmodule` is boring, that is why there are higher-arity versions of the macros.
Also, if the only refinement you want is a function, you can pass it directly (instead of the predicate
`[fun: &my_function/1]` you can pass `&my_function/1` directly)

You can use this to define the same schema in a different way:

```elixir
subtype(Name, Exchema.Types.String, [])
subtype(Continent, Exchema.Types.Atom, inclusion: ~w{europe north_america, south_america}a)
subtype(Country, Exchema.Types.Atom, inclusion: ~w{brazil canada portugal}a) do
  def continent_for(country) do
    # ...
  end
end
subtype(Metadata, :any, &(is_list(&1) || is_map(&1)))
structure(FullName, first: Name, last: Name)
structure(
  MyStructure,
  [
    name: FullName,
    country: Country,
    continent: Continent,
    metadata: Metadata
  ]
) do
  refine([fun: fn %{country: country, continent: continent} ->
    Country.continent_for(country) == continent
  end])
end
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
`{Exchema.Types.Map, {Exchema.Types.String, Exchema.Types.Integer}}` represents
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

## Installation

Add `exchema` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exchema, "~> 0.3.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exchema](https://hexdocs.pm/exchema).
