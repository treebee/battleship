defmodule BattleshipWeb.GamePreparationTest do
  use BattleshipWeb.ConnCase
  use Battleship.Fixtures, [:game]

  import Phoenix.LiveViewTest

  alias Battleship.Games

  def login(conn, credentials) do
    post(conn, Routes.login_path(conn, :login), credentials: credentials)
  end

  def set_ships(view) do
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

  test "user can set ships", %{conn: conn} do
    game = game_fixture()
    [player1, _] = game.participants

    conn = login(conn, %{username: player1.username, return_to: "/"})

    {:ok, view, _html} = live(conn, "/games/#{game.id}")

    set_ships(view)

    view |> element("button", "Ready") |> render_click()

    game = Games.get_game!(game.id)
    player = Games.get_player(game, player1.username)
    assert length(player.ships) == 5
  end

  test "user can toggle ships", %{conn: conn} do
    game = game_fixture()
    [player1, _] = game.participants
    conn = login(conn, %{username: player1.username, return_to: "/"})
    {:ok, view, _html} = live(conn, "/games/#{game.id}")

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
end
