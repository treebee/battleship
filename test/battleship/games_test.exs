defmodule Battleship.GamesTest do
  use Battleship.DataCase

  alias Battleship.Games

  test "can create game" do
    {:ok, game} = Games.create_game()
    assert game.id != nil
  end

  test "can add players to game" do
    {:ok, game} = Games.create_game()
    {:ok, player1} = Games.add_player(game, "player1")
    {:ok, player2} = Games.add_player(game, "player2")
    game = Games.get_game!(game.id)
    assert [player1, player2] == game.participants
  end

  test "list games" do
    {:ok, game} = Games.create_game()
    assert [game] == Games.list_games()
  end
end
