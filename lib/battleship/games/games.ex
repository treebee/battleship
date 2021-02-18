defmodule Battleship.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Battleship.Repo

  alias Battleship.Game
  alias Battleship.Ships
  alias Battleship.Participant

  def subscribe(id) do
    BattleshipWeb.Endpoint.subscribe("game:#{id}")
  end

  def broadcast(id, event) do
    BattleshipWeb.Endpoint.broadcast!("game:#{id}", event, "")
  end

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Returns a list of games a certain user with given `username` can still (re)join.

  ## Examples

      iex> get_game_list("patrick")
      [%Game{}, ...]

  """
  def get_game_list(username) do
    Repo.all(
      from g in Game,
        join: p in Participant,
        on: p.game_id == g.id,
        where: g.state == :created or (g.state == :started and p.username != ^username),
        group_by: g.id
    )
    |> Repo.preload(:participants)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id) |> Repo.preload(:participants)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def get_player(%Game{} = game, username) do
    Repo.get_by(Participant, game_id: game.id, username: username)
  end

  def get_opponent(%Game{} = game, username) do
    game.participants
    |> Enum.filter(fn participant -> participant.username != username end)
    |> List.first()
  end

  def add_player(%Game{} = game, username) do
    %Participant{}
    |> Participant.changeset(%{game_id: game.id, username: username})
    |> Repo.insert()
  end

  def start_game(%Game{} = game) do
    {:ok, _start_player} = choose_start_player(game)

    case update_game(game, %{state: :started}) do
      {:ok, game} ->
        broadcast(game.id, "start_game")
        {:ok, game |> Repo.preload(:participants)}

      {:error, error} ->
        IO.puts(:stderr, error)
    end
  end

  defp choose_start_player(%Game{} = game) do
    game.participants
    |> Enum.random()
    |> Participant.changeset(%{is_start_player: true})
    |> Repo.update()
  end

  def set_ships(participant, ships) do
    ships =
      ships
      |> Enum.map(fn {{x, y}, ship} ->
        %{name: ship.name, direction: ship.direction, size: ship.size, x: x, y: y}
      end)

    participant
    |> Participant.changeset(%{ships: ships})
    |> Repo.update()
  end

  def winner(game) do
    game.participants |> Enum.filter(fn p -> has_won?(p) end) |> List.first()
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
