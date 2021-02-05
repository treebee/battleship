defmodule Battleship.Repo.Migrations.AddGameStateColumn do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :state, :string, default: "created"
    end
  end
end
