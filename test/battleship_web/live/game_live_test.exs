defmodule BattleshipWeb.GameLiveTest do
  use BattleshipWeb.ConnCase
  use Battleship.Fixtures, [:game]
  use BattleshipWeb.Fixtures, [:login]

  import Phoenix.LiveViewTest

  alias Battleship.Games
  alias Battleship.Participants

  test "user can set ships", %{conn: conn} do
    game = game_fixture()
    [player1, _] = game.participants

    {:ok, view, _html} =
      conn
      |> login(%{username: player1.username, return_to: "/"})
      |> live("/games/#{game.id}")

    set_ships(view)

    view |> element("button", "Ready") |> render_click()

    game = Games.get_game!(game.id)
    player = Games.get_player(game, player1.username)
    assert length(player.ships) == 5
  end

  test "user can toggle ships", %{conn: conn} do
    game = game_fixture()
    [player1, _] = game.participants

    {:ok, view, _html} =
      conn
      |> login(%{username: player1.username, return_to: "/"})
      |> live("/games/#{game.id}")

    set_ships(view)

    view |> element("#cruiser") |> render_click()
    view |> element("#battleship") |> render_click()

    view |> element("button", "Ready") |> render_click()

    game = Games.get_game!(game.id)
    player = Games.get_player(game, player1.username)
    cruiser = Enum.find(player.ships, fn ship -> ship.name == "cruiser" end)
    assert cruiser.direction == "x"
    battleship = Enum.find(player.ships, fn ship -> ship.name == "battleship" end)
    assert battleship.direction == "y"
  end

  test "game starts when both players ready", %{conn: conn} do
    game = game_fixture(%{setup_players: 1})
    [_, player] = game.participants

    {:ok, view, _html} =
      conn
      |> login(%{username: player.username, return_to: "/"})
      |> live("/games/#{game.id}")

    set_ships(view)

    assert game.state == :created
    view |> element("button", "Ready") |> render_click()
    game = Games.get_game!(game.id)
    assert game.state == :started
    assert Enum.filter(game.participants, fn p -> p.is_start_player end) |> length() == 1
  end

  test "players can shoot", %{conn: conn} do
    game = game_fixture(%{setup_players: 1})
    [_, player] = game.participants
    conn = login(conn, %{username: player.username, return_to: "/"})

    {:ok, view, _html} = live(conn, "/games/#{game.id}")

    set_ships(view)
    view |> element("button", "Ready") |> render_click()
    game = Games.get_game!(game.id)

    player = Games.get_start_player(game)

    make_turn(conn, player, game, {0, 1})

    player = Participants.get_participant!(player.id)
    assert length(player.shots) == 1
    [shot] = player.shots
    assert shot.x == 0
    assert shot.y == 1
    assert shot.hit
  end

  test "player cannot shoot 2 times in a row", %{conn: conn} do
    game = game_fixture(%{setup_players: 1})
    [_, player] = game.participants
    conn = login(conn, %{username: player.username, return_to: "/"})

    {:ok, view, _html} = live(conn, "/games/#{game.id}")

    set_ships(view)
    view |> element("button", "Ready") |> render_click()
    game = Games.get_game!(game.id)

    [player1, player2] = game.participants

    player =
      cond do
        Participants.their_turn?(player1) -> player1
        Participants.their_turn?(player2) -> player2
      end

    make_turn(conn, player, game, {0, 1})
    make_turn(conn, player, game, {1, 1})

    player = Participants.get_participant!(player.id)
    assert length(player.shots) == 1
  end

  test "player cannot shoot twice at same spot", %{conn: conn} do
    game = game_fixture(%{setup_players: 1})
    [_, player] = game.participants
    conn = login(conn, %{username: player.username, return_to: "/"})

    {:ok, view, _html} = live(conn, "/games/#{game.id}")

    set_ships(view)
    view |> element("button", "Ready") |> render_click()
    game = Games.get_game!(game.id)

    player = Games.get_start_player(game)

    make_turn(conn, player, game, {0, 1})
    opponent = Participants.get_opponent(player)
    make_turn(conn, opponent, game, {0, 1})
    make_turn(conn, player, game, {0, 1})

    player = Participants.get_participant!(player.id)
    assert length(player.shots) == 1

    opponent = Participants.get_participant!(opponent.id)
    assert length(opponent.shots) == 1

    make_turn(conn, player, game, {3, 1})

    player = Participants.get_participant!(player.id)
    assert length(player.shots) == 2
  end

  test "user can join a game", %{conn: conn} do
    {:ok, game} = Games.create_game()
    {:ok, _} = Games.add_player(game, "player1")
    conn = login(conn, %{username: "SomeRandomUsername", return_to: "/"})

    {:ok, _view, html} = live(conn, "/games/#{game.id}")

    assert html =~ "Drag the ship on to the grid."
  end

  test "only 2 players can join a game", %{conn: conn} do
    game = game_fixture(%{setup_players: 2})
    conn = login(conn, %{username: "SomeRandomUsername", return_to: "/"})

    {:ok, _view, html} = live(conn, "/games/#{game.id}") |> follow_redirect(conn)
    assert html =~ "Game already has 2 players!"
  end

  test "game finishes when a player wins", %{conn: conn} do
    game = game_almost_done()
    player = Games.get_start_player(game)
    make_turn(conn, player, game, {0, 0})
    opponent = Participants.get_opponent(player)

    {:ok, _view, html} =
      conn
      |> login(%{username: opponent.username, return_to: "/"})
      |> live("/games/#{game.id}")

    assert html =~ "#{player.username} won the game!"
  end

  test "user can use airstrikes", %{conn: conn} do
    game = game_fixture(%{setup_players: 1})
    [opponent, player] = game.participants
    conn = login(conn, %{username: player.username, return_to: "/"})

    {:ok, view, _html} = live(conn, "/games/#{game.id}")

    set_ships(view)
    view |> element("button", "Ready") |> render_click()
    Participants.update_participant(player, %{is_start_player: true})
    Participants.update_participant(opponent, %{is_start_player: false})
    game = Games.get_game!(game.id)

    {:ok, view, _html} =
      conn
      |> live("/games/#{game.id}")

    assert Participants.count_hits(player) == 0

    view
    |> render_keyup("switch_weapon", %{"key" => " "})

    view
    |> element("#cell-3-0")
    |> render_click()

    player = Participants.get_participant!(player.id)
    assert Participants.count_hits(player) == 5
  end

  defp make_turn(conn, player, game, {x, y}) do
    {:ok, view, _html} =
      conn
      |> login(%{username: player.username, return_to: "/"})
      |> live("/games/#{game.id}")

    view
    |> element("#cell-#{x}-#{y}")
    |> render_click()

    # we wait here a moment to make sure that the database updates are done
    Process.sleep(500)
  end

  defp set_ships(view) do
    view
    |> render_hook("add_ship", %{
      "x" => 0,
      "y" => 0,
      "id" => "lobbycarrier",
      "size" => 5,
      "direction" => "y"
    })

    view
    |> render_hook("add_ship", %{
      "x" => 1,
      "y" => 0,
      "id" => "lobbybattleship",
      "size" => 4,
      "direction" => "y"
    })

    view
    |> render_hook("add_ship", %{
      "x" => 2,
      "y" => 0,
      "id" => "lobbydestroyer",
      "size" => 2,
      "direction" => "y"
    })

    view
    |> render_hook("add_ship", %{
      "x" => 6,
      "y" => 0,
      "id" => "lobbycruiser",
      "size" => 3,
      "direction" => "y"
    })

    view
    |> render_hook("add_ship", %{
      "x" => 4,
      "y" => 0,
      "id" => "lobbysubmarine",
      "size" => 3,
      "direction" => "y"
    })
  end
end
