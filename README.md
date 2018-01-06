# Exchema

**TODO: Add description**

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
