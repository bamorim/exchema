# Types

The idea of refinement types is based on set theory. We think about
sets of values and how to define narrower sets through types. This
guide does not aim to explain set theory but to help thinking about
refinement types for validation.

## `:any` type and anything values

Think about input data as the set of all possible values. They are 
*anything*. So, we can say that they are all contained in the `:any` 
set of possible values.

That is why we call `:any` the **root** parent type as any value derives
from `:any`.

## Narrowing the possible values

In reality we don't want ANY value in our system. Normally we have a very
good idea of the possible values. That is: we want a **subset** of all
possible values. 

Let's think of an example: user ID. Normally we use this for fetching the
user through some REST API. Because we strive for good APIs, we use an 
UUID instead of a long. We want to avoid people trying to guess the next 
id or the first id. 

Now, normally, an UUID is represented as a string. This is the first 
refinement we want to make: *out of all possible values we want only those
that are strings*.

Even then, there are infinite possible strings that are not valid UUIDs. 
This is why we refine it even more. We want a smaller subset of all possible
values: it needs to be a certain group of strings. 

To do that, we can define a subtype of a String:

``` elixir
subtype Id, Exchema.Types.String, []
```

With that declaration we have a name for a new set of possible values. The way
it is now means this subset is exactly the same as the string subset. We need
to refine it further:

``` elixir
subtype Id, Exchema.Types.String, fn val ->
  String.length(val) == 36 
end
```

That creates a subset of all string possible values. Now this subset contains a
finite number of possible values: all strings with length 36. But we can do 
better. Let's use the UUID library from hex to narrow it down only to valid
uuids type 4 formatted according to standard notation:

``` elixir
subtype(
  Id,
  Exchema.Types.String,
  fn val ->
    with {:ok, opts} <- UUID.info(val), # returns details about val
         4 <- opts[:version],           # ensure it is version 4
         :default <- opts[:type] do     # ensure only the standard format
      {:ok, val}
    else
      _ ->
        {:error, :not_valid_uuid}
    end
  end
)
```

Now we can be sure that this subtype is delimiting all the possible values we
want. Anywhere we declare `Id` type now can be validate to be in the subset of
possible uuid v4 standard formatted values. 

Details about what should be returned in the function are on the Predicates guide.

## Defining custom types

Other than using the `subtype/3` macro, you can define your types implementing 
the `__type__/1` function. Let's see, for instance, how the `Exchema.Types.DateTime`
is implemented:

``` elixir
defmodule Exchema.Types.DateTime do
def __type__({}) do
    {:ref, :any, [{{Exchema.Predicates, :is_struct}, DateTime}]}
  end
end
```

More details about the format of the tuple in the Predicates guide. You can also see 
the checking types guide for valiadtion errors.

