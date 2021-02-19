defmodule Battleship.Participants do
  alias Battleship.Games
  alias Battleship.Shot
  alias Battleship.Ships
  alias Battleship.Participant
  alias Battleship.Repo

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  def add_shot(%Participant{} = participant, %Shot{} = shot) do
    participant
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:shots, [shot | participant.shots])
    |> Repo.update()
  end

  def ready?(%Participant{} = player) do
    length(player.ships) == 5
  end

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
        hit = is_hit?({x, y}, opponent)
        max_turn = length(participant.shots)

        shot = %Shot{
          turn: max_turn + 1,
          x: x,
          y: y,
          hit: hit
        }

        add_shot(participant, shot)
    end
  end

  @spec is_hit?({integer, integer}, %Battleship.Participant{}) :: boolean
  def is_hit?({x, y}, %Participant{} = opponent) do
    opponent.ships
    |> Enum.map(&Ships.is_hit?(&1, {x, y}))
    |> Enum.any?()
  end

  @spec has_won?(%Battleship.Participant{}) :: boolean
  def has_won?(%Participant{} = participant) do
    participant.shots
    |> Enum.filter(fn shot -> shot.hit end)
    |> length() == 17
  end
end
