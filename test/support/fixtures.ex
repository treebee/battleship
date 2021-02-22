defmodule Battleship.Fixtures do
  @moduledoc """
  Defines fixtures that can be used in tests, like setting up
  a Game with its 2 players.

  This module can be used with a list of fixtures to apply as parameter:

    use Battleship.Fixtures, [:game]
  """
  use Wallaby.DSL

  def game do
    alias Battleship.Games

    quote do
      def game_fixture() do
        {:ok, game} = Games.create_game()
        {:ok, player1} = Games.add_player(game, "player1")
        {:ok, player2} = Games.add_player(game, "player2")
        Games.get_game!(game.id)
      end
    end
  end

  def login do
    quote do
      def do_login(session, username) do
        session
        |> visit("/")
        |> fill_in(Query.css("#credentials_username"), with: username)
        |> click(Query.button("login"))
      end
    end
  end

  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
