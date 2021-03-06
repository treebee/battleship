defmodule Battleship.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "games" do
    field :state, Ecto.Enum, values: [:created, :started, :finished], default: :created
    field :secret, :boolean, default: false
    has_many :participants, Battleship.Participant
    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:state, :secret])
    |> validate_required([:state])
  end
end
