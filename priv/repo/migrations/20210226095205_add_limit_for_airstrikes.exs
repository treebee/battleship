defmodule Battleship.Repo.Migrations.AddLimitForAirstrikes do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :num_airstrikes, :integer
    end
  end
end
