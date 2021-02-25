defmodule Battleship.Shot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :turn, :integer, primary_key: true
    field :x, :integer
    field :y, :integer
    field :hit, :boolean
    field :type, Ecto.Enum, values: [:torpedo, :radar, :airstrike], default: :torpedo

    embeds_many :strikes, Strike do
      field :x, :integer
      field :y, :integer
      field :hit, :boolean
    end
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:turn, :x, :y, :hit, :type])
    |> cast_embed(:strikes, with: &strike_changeset/2)
    |> validate_required([:turn, :x, :y, :hit])
  end

  defp strike_changeset(schema, params) do
    schema
    |> cast(params, [:x, :y, :hit])
  end
end
