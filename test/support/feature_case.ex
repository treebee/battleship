defmodule BattleshipWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      alias BattleshipWeb.Router.Helpers, as: Routes

      @endpoint BattleshipWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Battleship.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Battleship.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Battleship.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
