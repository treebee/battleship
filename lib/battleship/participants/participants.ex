defmodule Battleship.Participants do
  alias Battleship.Games
  alias Battleship.Shot
  alias Battleship.Participant
  alias Battleship.Repo

  def their_turn?(%Participant{} = player) do
    case Games.get_game!(player.game_id).participants
         |> Enum.map(fn participant -> length(participant.shots) end)
         |> Enum.sum()
         |> rem(2) do
      0 -> player.is_start_player
      _ -> not player.is_start_player
    end
  end

  def get_opponent(%Participant{} = participant) do
    game =
      participant.game_id
      |> Games.get_game!()

    game.participants
    |> Enum.filter(fn p -> p.username != participant.username end)
    |> List.first()
  end

  def shoot(%Participant{} = participant, {x, y}) when not is_integer(x) do
    shoot(%Participant{} = participant, {String.to_integer(x), String.to_integer(y)})
  end

  def shoot(%Participant{} = participant, {x, y}) do
    opponent = get_opponent(participant)

    cond do
      {x, y} in (participant.shots |> Enum.map(fn shot -> {shot.x, shot.y} end)) ->
        {:error, "Already shot at {#{x}, #{y}}"}

      true ->
        hit = Games.is_hit?({x, y}, opponent)
        max_turn = length(participant.shots)

        shot = %Shot{
          turn: max_turn + 1,
          x: x,
          y: y,
          hit: hit
        }

        participant
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_embed(:shots, [shot | participant.shots])
        |> Repo.update()
    end
  end
end
