defmodule Battleship.Ship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string, primary_key: true
    field :direction
    field :size, :integer
    field :x, :integer
    field :y, :integer
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:name, :direction, :size, :x, :y])
    |> validate_required([:name, :direction, :size])
  end
end
