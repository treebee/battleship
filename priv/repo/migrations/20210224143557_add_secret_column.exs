defmodule Battleship.Repo.Migrations.AddSecretColumn do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :secret, :boolean
    end
  end
end
