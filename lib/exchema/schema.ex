defmodule Exchema.Schema do
  @moduledoc """
  Defines the DSL for defining a schema
  """
  @type field :: [Exchema.Transformer.spec] | t
  @type t :: %{required(any) => field} | module

  def __using__ do
    quote do
      import Exchema.Schema, only: [schema: 1]
    end
  end

  defmacro schema([do: block]) do
    quote do
      Module.register_attribute(__MODULE__, :exchema_depth_counter, [])
      Module.put_attribute(__MODULE__, :exchema_depth_counter, 0)
      Module.register_attribute(__MODULE__, :exchema_fields_0, accumulate: true)

      try do
        import Exchema.Schema
        unquote(block)
      after
        :ok
      end

      Module.put_attribute(__MODULE__, :exchema_fields,
        __MODULE__
        |> Module.get_attribute(:exchema_fields_0)
        |> Enum.into(%{})
      )
      Module.delete_attribute(__MODULE__, :exchema_depth_counter)
      Module.delete_attribute(__MODULE__, :exchema_fields_0)

      def __exchema__ do
        @exchema_fields
      end
    end
  end

  defmacro field(name, args \\ []) do
    quote do
      depth = Module.get_attribute(__MODULE__, :exchema_depth_counter)
      Module.put_attribute(
        __MODULE__,
        :"exchema_fields_#{depth}",
        {unquote(name), unquote(args)}
      )
    end
  end

  defmacro nested(name, [do: block]) do
    quote do
      prev_depth = Module.get_attribute(__MODULE__, :exchema_depth_counter)
      depth = prev_depth + 1
      Module.put_attribute(__MODULE__, :exchema_depth_counter, depth)
      Module.register_attribute(__MODULE__, :"exchema_fields_#{depth}", accumulate: true)

      unquote(block)

      # Register as a field
      Module.put_attribute(
        __MODULE__,
        :"exchema_fields_#{prev_depth}",
        {
          unquote(name),
          __MODULE__
          |> Module.get_attribute(:"exchema_fields_#{depth}")
          |> Enum.into(%{})
        }
      )

      Module.put_attribute(__MODULE__, :exchema_depth_counter, prev_depth)
      Module.delete_attribute(__MODULE__, :"exchema_fields_#{depth}")
    end
  end
end
