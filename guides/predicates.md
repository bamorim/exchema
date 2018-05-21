# Predicates

Predicate is how we can refine types. It narrows the possible input 
values down to those your type support. Let's see how `DateTime` type
is implemented:

``` elixir
defmodule Exchema.Types.DateTime do
  alias Exchema.Predicates

  def __type__({}) do
    {:ref, :any, [{{Predicates, :is_struct}, DateTime}]}
  end
end
```

