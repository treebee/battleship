defmodule Battleship.Shot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :turn, :integer, primary_key: true
    field :x, :integer
    field :y, :integer
    field :hit, :boolean
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:turn, :x, :y, :hit])
    |> validate_required([:turn, :x, :y, :hit])
  end
end
