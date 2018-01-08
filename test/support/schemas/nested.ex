defmodule Schemas.Nested do
  use Exchema

  schema do
    nested :nested do
      field :field, type: :integer
    end
  end
end
