# Exchema

This is still a WIP. More details later =D

## New Proposal

Implement a type system based on refinement types.
We will have the following native types:

```elixir
:any
:integer
:atom
:float
:string
{:list, type}
{:map, type, type}
```

And the following refinements

```
```

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
