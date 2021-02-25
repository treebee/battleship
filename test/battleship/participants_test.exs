defmodule Battleship.ParticipantsTest do
  use Battleship.DataCase
  alias Battleship.Games
  alias Battleship.Participants
  alias Battleship.Shot

  defp fixture() do
    {:ok, game} = Games.create_game()
    Games.add_player(game, "player1")
    Games.add_player(game, "opponent")
    game = Games.get_game!(game.id)
    {:ok, game} = Games.start_game(game)
    Games.get_game!(game.id)
  end

  test "get opponent" do
    game = fixture()
    [player, opponent] = game.participants
    assert Participants.get_opponent(player).username == opponent.username
  end

  test "is players turn" do
    game = fixture()
    [player, opponent] = game.participants
    assert player.is_start_player == Participants.their_turn?(player)
    assert opponent.is_start_player == Participants.their_turn?(opponent)
  end

  test "player can shoot" do
    game = fixture()
    [start_player] = game.participants |> Enum.filter(fn p -> p.is_start_player end)
    {:ok, start_player} = Participants.shoot(start_player, {4, 4})
    assert length(start_player.shots) == 1
  end

  test "player cannot shoot multiple times at same spot" do
    game = fixture()
    [start_player] = game.participants |> Enum.filter(fn p -> p.is_start_player end)
    {:ok, start_player} = Participants.shoot(start_player, {4, 4})
    {:error, _error} = Participants.shoot(start_player, {"4", "4"})
  end

  test "correctly calculates hits" do
    game = fixture()
    [player, _] = game.participants

    shots = [
      %Shot{x: 0, y: 0, hit: true, turn: 3, type: :torpedo},
      %Shot{x: 0, y: 1, hit: true, turn: 2, type: :torpedo},
      %Shot{
        x: 1,
        y: 1,
        hit: true,
        turn: 1,
        type: :airstrike,
        strikes: [
          %{x: 0, y: 0, hit: true},
          %{x: 0, y: 1, hit: true},
          %{x: 0, y: 2, hit: true},
          %{x: 1, y: 0, hit: true},
          %{x: 1, y: 1, hit: false},
          %{x: 1, y: 2, hit: false},
          %{x: 2, y: 0, hit: false},
          %{x: 2, y: 1, hit: false},
          %{x: 2, y: 2, hit: false}
        ]
      }
    ]

    player = %{player | shots: shots}
    assert Participants.count_hits(player) == 4
  end
end
