# Checking types

For checking input in `Exchema` you call the validation function 
`is?/2`. It receives the input and the type for running checks.

``` elixir
iex> Exchema.is?("1234", Exchema.Types.String)
true

iex> Exchema.is?(1234, Exchema.Types.String)
false

iex> Exchema.is?(1234, Exchema.Types.Integer)
true
```

## Types

Now that checking is out of the way. Let's extend to what is a type. 

It can be:

- the global type `:any`
- a type reference such as `Exchema.Types.String`
- a type refinement such as `{:ref, :any, length: 1}` (more about this in predicates guide)
- a type application (for parametric types) such as `{Exchema.Types.List, Exchema.Types.String}`


## Errors

When checking returns false, we can see what caused that with the
`errors/2` function:

``` elixir
iex> Exchema.errors(1234, Exchema.Types.String)
[{{Exchema.Predicates, :is}, :binary, :not_a_binary}]
```

This is also helpful when you have several errors. Let's check that:

``` elixir
# import the DSL
import Exchema.Notation

# alias the types
alias Exchema.Types, as: T

# define a User structure
structure User, first_name: T.String, last_name: T.String

# Type this on iex
iex> Exchema.errors(%User{first_name: 123, last_name: 123}, User)
[
  {{Exchema.Predicates, :fields},
   [first_name: Exchema.Types.String, last_name: Exchema.Types.String],
   {:nested_errors,
    [
      first_name: [{{Exchema.Predicates, :is}, :binary, :not_a_binary}],
      last_name: [{{Exchema.Predicates, :is}, :binary, :not_a_binary}]
    ]}}
]
```

## Flatten errors

We can also flatten the errors for better reading:

``` elixi
iex> errors = Exchema.errors(%User{first_name: 123, last_name: 123}, User) 
# output omitted
iex> Exchema.flatten_errors(errors)
[
  {[:first_name], {Exchema.Predicates, :is}, :binary, :not_a_binary},
  {[:last_name], {Exchema.Predicates, :is}, :binary, :not_a_binary}
]
```

This is very useful for debugging errors.

## Nested types

You can nest types without issues and check nested errors. Example:

```elixir
import Exchema.Notation

# Name here has no predicate other than its super type. You might want
# to add predicates later like checking if its upcased.
subtype Name, Exchema.Types.String, []

# This is a different type of predicate than 'is'. 
subtype Country, Exchema.Types.Atom, [inclusion: ~w{brazil canada portugal}a]

# This extends from `:any` because list and maps descend from any
subtype Metadata, :any, &(is_list(&1) || is_map(&1))

structure FullName, [first: Name, last: Name]

defmodule MyStructure do
  structure [
    name: FullName, # nested model
    country: Country, 
    metadata: Metadata # generic data
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

