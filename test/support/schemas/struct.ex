defmodule Schemas.Struct do
  use Exchema

  schema struct: true do
    field :field, type: :integer
  end
end
