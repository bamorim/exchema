# Introduction

Exchema is a library to define and validate data. It allows
you to check the type for a given value at runtime (it is **not** static
type checking).

The type definition allows us to build other nice libraries on top of it like [`exchema_coercion`](https://github/bamorim/exchema_coercion) and [`exchema_stream_data`](https://github.com/bamorim/exchema_stream_data)

It uses the idea of **refinement types**, in which we have a global type
(which all values belong) and can refine that type with the use of
**predicates**.

The root type is `:any`. From there we can declare subtypes with refinements
to reach the boundaries of possible values we want. The library comes with 
several built-in type definitions for native types.

Let's use the built-in types to show an example:

``` elixir
import Exchema.Notation # this is the entrypoint for the DSL

# Let's declare a type that is a subtype of String
subtype Name, Exchema.Types.String, [] 

# Now we have :any <- String <- Name

# Let's declare a structure using this type:
# here we use the structure macro which accepts an atom as the
# name for the structure. This will generate a struct so think of
# it as a different `defstruct` call
structure Names, [first: Name, last: Name]

# Pay attention at the 'default' values. They are type definitions.
# With that we can validate input.
    
# That was easy.

# Let's check if it is valid according to our refinements:
true = Exchema.is?(names, Names)
```

Nice. Although it does not look much, this is very powerful! Let's see
a more complex example.

Let's define an `Id` type. This will use the library `UUID` from hex just
as an example.

``` elixir
subtype(
  Id,
  Exchema.Types.String,
  fn val ->   # this is our refinement 
    with {:ok, opts} <- UUID.info(val), # checks it is proper formed
         4 <- opts[:version],           # it is version 4
         :default <- opts[:type] do     # it is formatted as the default option
      {:ok, val} 
    else
      _ ->
        {:error, :not_valid_uuid}       # not valid UUID
    end
  end
)
```

Now if we want to declare a user we can do this:

``` elixir
structure User, [
    id: Id,
    first_name: Name,
    last_name: Name
  ]
```

Awesome. Let's again validate:

``` elixir
user = %User{id: nil, first_name: "Hello", last_name: "World"}
```

But... wait! `id` nil is valid? Well, let's validate to check:

``` elixir
Exchema.is?(user, User)
# false
```

We haven't declared `id` as **optional**. So, the structure is not valid.

Let's fix our declaration and run again:

``` elixir
structure User, [
    id: {Exchema.Types.Optional, Id},
    first_name: Name,
    last_name: Name
  ]
```

Wow. That is new. That is a *parametric type* (or parameterized type). It is
used for occasions like this one: the parameter can be either `nil` or an 
`Id`.

It is also useful when you want to work with collection of elements like lists
and maps. See the collections guide.

Let's now validate again:

``` elixir
Exchema.is?(user, User)
# true
```

All right! That covers the basics.

See the Types guide for understanding the core concept behind refinement types.