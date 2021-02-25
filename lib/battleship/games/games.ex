defmodule Battleship.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Battleship.Repo

  alias Battleship.Game
  alias Battleship.Participant
  alias Battleship.Participants

  def ready?(%Game{} = game) do
    length(game.participants) == 2 and
      game.participants
      |> Enum.map(&Participants.ready?/1)
      |> Enum.all?()
  end

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(from g in Game, order_by: g.inserted_at)
  end

  @doc """
  Returns a list of games a certain user with given `username` can still (re)join.

  ## Examples

      iex> get_game_list("patrick")
      [%Game{}, ...]

  """
  def get_game_list(nil), do: []

  def get_game_list(username) do
    Repo.all(
      from g in Game,
        join: p in Participant,
        on: p.game_id == g.id,
        where:
          (g.state == :created or
             (g.state == :started and p.username != ^username)) and
            (is_nil(g.secret) or
               (not g.secret or
                  p.username == ^username)),
        group_by: g.id,
        order_by: g.inserted_at
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
    |> broadcast("game_created")
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

  @doc """
  Creates a participant with the given `username` or returns an error
  in case the game already has two participants.
  """
  def add_player(%Game{} = game, username) do
    Participants.create_participant(%{game_id: game.id, username: username})
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

  def start_game!(%Game{} = game) do
    {:ok, game} = start_game(game)
    game
  end

  defp choose_start_player(%Game{} = game) do
    game.participants
    |> Enum.random()
    |> Participants.update_participant(%{is_start_player: true})
  end

  def get_start_player(game) do
    case game.participants do
      [player1, player2] ->
        cond do
          Participants.their_turn?(player1) -> player1
          Participants.their_turn?(player2) -> player2
        end

      [_player1] ->
        nil

      _ ->
        nil
    end
  end

  def winner(game) do
    game.participants |> Enum.filter(&Participants.has_won?/1) |> List.first()
  end

  def subscribe() do
    BattleshipWeb.Endpoint.subscribe("games")
  end

  def subscribe(id) do
    BattleshipWeb.Endpoint.subscribe("game:#{id}")
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, game}, event) do
    if not game.secret do
      BattleshipWeb.Endpoint.broadcast!("games", event, game)
    end

    {:ok, game}
  end

  def broadcast(id, event, payload \\ "") do
    BattleshipWeb.Endpoint.broadcast!("game:#{id}", event, payload)
  end
end
