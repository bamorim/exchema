# Exchema

This is still a WIP. More details later =D

## Installation

Add `exchema` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exchema, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exchema](https://hexdocs.pm/exchema).

## Internals

Exchema works with some important pieces:

- Transformer
  It is the common definition between a coercion and a validation.
  
  It is a function that receives a value, a list of arguments and returns either
  an `{:error, description}` or an `:ok` or `{:ok, new_value}`
  
  I.E., a validation returns either an error or an ok whilist a coercion returns
  either a new value or an error.

- TransformerFinder
  This implements a function that receives a transformation definition and
  returns either nil or a transformer.

## Work to do

- [X] Define schema internal representation
- [X] Create parser that parses and transforms a given input
- [X] Create DSL to 
- [X] Allow DSL to generate struct
- [ ] Add schema-level transformations
- [ ] Implement type coercion for
  - [X] Integer
  - [ ] Float
  - [ ] Date (ISO 8601)
  - [ ] Time (ISO 8601)
  - [ ] NaiveDateTime (ISO 8601)
  - [ ] DateTime (ISO 8601)
  - [ ] Other Schemas
- [ ] Implement transformaitons for the following libs (and extract later)
  - [ ] UUID
  - [ ] Vex (validation)

Maybe the generation of struct can be defined as a after-schema def plugin that
would enable other extensions such as generating a Ecto.Schema (bonus for generating
changeset validations automagically) in external libraries.
