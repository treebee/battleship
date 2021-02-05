defmodule Battleship.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :username, :string
      add :shots, :map
      add :ships, :map
      add :game_id, references(:games, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:participants, [:game_id])
  end
end
