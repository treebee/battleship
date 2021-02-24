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

  test "game cannot have more than two players" do
    {:ok, game} = Games.create_game()
    {:ok, _player1} = Games.add_player(game, "player1")
    {:ok, _player2} = Games.add_player(game, "player2")
    {:error, error} = Games.add_player(game, "player3")
    assert error == "A Game cannot have more than 2 participants!"
  end
end
