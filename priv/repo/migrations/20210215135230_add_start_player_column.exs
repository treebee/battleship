defmodule Battleship.Repo.Migrations.AddStartPlayerColumn do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :is_start_player, :boolean
    end
  end
end
