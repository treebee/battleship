defmodule Battleship.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Battleship.Ship
  alias Battleship.Shot

  schema "participants" do
    embeds_many :ships, Ship
    embeds_many :shots, Shot
    field :username, :string
    field :is_start_player, :boolean, default: false
    field :num_airstrikes, :integer, default: 1
    belongs_to :game, Battleship.Game, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:game_id, :username, :is_start_player, :num_airstrikes])
    |> cast_embed(:ships, with: &Battleship.Ship.changeset/2)
    |> cast_embed(:shots, with: &Battleship.Shot.changeset/2)
    |> validate_required([:username, :game_id])
  end
end
