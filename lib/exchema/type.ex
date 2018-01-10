defmodule Exchema.Type do
  alias Exchema.Predicate

  @type t :: module
  @type type_params :: tuple
  @type type_reference :: t | {t, type_params}
  @type refined_type :: {:ref, t, [Predicate.spec]}
  @type spec :: type_reference | refined_type

  @callback __type__(type_params) :: spec
end
