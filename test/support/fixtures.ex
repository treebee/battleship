defmodule Battleship.Fixtures do
  @moduledoc """
  Defines fixtures that can be used in tests, like setting up
  a Game with its 2 players.

  This module can be used with a list of fixtures to apply as parameter:

    use Battleship.Fixtures, [:game]
  """

  def game do
    alias Battleship.Games
    alias Battleship.Participants

    quote do
      def game_fixture(opts \\ %{}) do
        {:ok, game} = Games.create_game()
        {:ok, player1} = Games.add_player(game, "player1")
        {:ok, player2} = Games.add_player(game, "player2")
        players_to_setup = Map.get(opts, :setup_players, 0)

        case players_to_setup do
          1 ->
            Participants.set_ships(player1)

          2 ->
            Participants.set_ships(player1)
            Participants.set_ships(player2)

          0 ->
            ""
        end

        Games.get_game!(game.id)
      end

      def game_almost_done() do
        alias Battleship.Ships
        alias Battleship.Shot

        {:ok, game} = Games.create_game()
        {:ok, player1} = Games.add_player(game, "player1")
        {:ok, player2} = Games.add_player(game, "player2")
        {:ok, player1} = Participants.set_ships(player1)
        {:ok, player2} = Participants.set_ships(player2)

        shots =
          player1.ships
          |> Enum.map(&Ships.cells/1)
          |> List.flatten()
          |> tl
          |> Enum.with_index()
          |> Enum.map(fn {{x, y}, i} -> %{x: x, y: y, hit: true, turn: i} end)

        Participants.update_participant(player1, %{shots: shots})
        Participants.update_participant(player2, %{shots: shots})

        Games.start_game!(Games.get_game!(game.id))
        Games.get_game!(game.id)
      end
    end
  end

  def login() do
    alias BattleshipWeb.Router.Helpers, as: Routes

    quote do
      def login(conn, credentials) do
        post(conn, Routes.login_path(conn, :login), credentials: credentials)
      end
    end
  end

  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
