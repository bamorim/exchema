defmodule Notation.TypespecTest do
  use ExUnit.Case

  defmodule ExposeTypeSpec do
    defmacro __before_compile__(_) do
      quote do
        def __typespec, do: @type
      end
    end
  end

  defmodule Complex do
    import Exchema.Notation
    alias Exchema.Types, as: T
  
    structure [
      key: {T.List, {T.Map, {T.String, {T.Optional, T.DateTime}}}},
      f: T.Float,
      pf: T.Float.Positive,
      i: T.Integer,
      nni: T.Integer.NonNegative,
      pi: T.Integer.Positive,
      ni: T.Integer.Negative,
      s: T.String,
      d: T.Date,
      dt: T.DateTime,
      ndt: T.NaiveDateTime,
      t: T.Time,
      st: T.Struct,
      m: T.Map,
      a: T.Atom,
      b: T.Boolean
    ]
    
    @before_compile ExposeTypeSpec
  end

  test "it generates a typespec" do
    assert [_ | _] = Complex.__typespec
  end

  test "it contains all structure fields" do
    [{_,{_,_,[{_,_,_},{_,_,[{_,_,_},{_,_,fields}]}]},_}] = Complex.__typespec
    keys = fields |> Enum.map(fn {k,_v} -> k end) |> Enum.sort

    assert [
      :a, :b, :d, :dt, :f, :i, :key, :m, :ndt, :ni, :nni, :pf, :pi, :s, :st, :t
    ] = keys
  end
end