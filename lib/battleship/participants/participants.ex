defmodule Battleship.Participants do
  alias Battleship.Games
  alias Battleship.Shot
  alias Battleship.Ships
  alias Battleship.Participant
  alias Battleship.Repo

  def get_participant!(id), do: Repo.get!(Participant, id)

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

  @doc """
  A simple helper to set all ships for given `participant` with a known
  configuration. Mostly useful for tests.
  """
  def set_ships(participant) do
    ships = [
      %{name: "carrier", size: 5, x: 0, y: 0, direction: "x"},
      %{name: "battleship", size: 4, x: 0, y: 1, direction: "x"},
      %{name: "cruiser", size: 3, x: 0, y: 2, direction: "x"},
      %{name: "submarine", size: 3, x: 0, y: 3, direction: "x"},
      %{name: "destroyer", size: 2, x: 0, y: 4, direction: "x"}
    ]

    update_participant(participant, %{ships: ships})
  end

  def set_ships(participant, ships) do
    ships =
      ships
      |> Enum.map(fn {{x, y}, ship} ->
        %{name: ship.name, direction: ship.direction, size: ship.size, x: x, y: y}
      end)

    update_participant(participant, %{ships: ships})
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

  def has_airstrikes_left?(participant) do
    participant = get_participant!(participant.id)

    case participant.num_airstrikes do
      nil -> false
      airstrikes -> airstrikes > 0
    end
  end

  def shoot(participant, coords, opponent \\ nil)

  def shoot(%Participant{} = participant, {x, y, type}, opponent)
      when not is_integer(x) do
    shoot(
      %Participant{} = participant,
      {String.to_integer(x), String.to_integer(y), type},
      opponent
    )
  end

  def shoot(%Participant{} = participant, {x, y, :airstrike}, opponent) do
    cond do
      has_airstrikes_left?(participant) ->
        opponent = if opponent, do: opponent, else: get_opponent(participant)
        strikes = for i <- -1..1, j <- -1..1, into: [], do: {x + i, y + j}

        strikes =
          Enum.map(strikes, fn {a, b} -> %{x: a, y: b, hit: is_hit?({a, b}, opponent)} end)

        max_turn = length(participant.shots)

        shot = %Shot{
          turn: max_turn + 1,
          x: x,
          y: y,
          hit: Enum.any?(strikes, fn strike -> strike.hit end),
          strikes: strikes,
          type: :airstrike
        }

        add_shot(participant, shot)

      true ->
        {:error, "No airstrikes left!"}
    end
  end

  def shoot(%Participant{} = participant, {x, y, :torpedo}, opponent) do
    opponent = if opponent, do: opponent, else: get_opponent(participant)

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

  def shoot(participant, {x, y, type}, opponent) when is_binary(type) do
    shoot(participant, {x, y, String.to_atom(type)}, opponent)
  end

  def shoot(participant, {x, y}, opponent), do: shoot(participant, {x, y, :torpedo}, opponent)

  @spec is_hit?({integer, integer}, %Battleship.Participant{}) :: boolean
  def is_hit?({x, y}, %Participant{} = opponent) do
    opponent.ships
    |> Enum.map(&Ships.is_hit?(&1, {x, y}))
    |> Enum.any?()
  end

  @spec has_won?(%Battleship.Participant{}) :: boolean
  def has_won?(%Participant{} = participant) do
    participant
    |> count_hits() == 17
  end

  def count_hits(%Participant{} = participant) do
    participant.shots
    |> Enum.map(&to_simple_shot/1)
    |> List.flatten()
    |> Map.new()
    |> Enum.count(fn {_, hit} -> hit end)
  end

  defp to_simple_shot(%{type: :airstrike, strikes: strikes}) do
    strikes |> Enum.map(&to_simple_shot/1)
  end

  defp to_simple_shot(%{x: x, y: y, hit: hit}) do
    {{x, y}, hit}
  end
end
