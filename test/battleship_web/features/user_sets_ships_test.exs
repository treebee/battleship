defmodule BattleshipWeb.UserSetsShipsTest do
  use BattleshipWeb.FeatureCase
  use Battleship.Fixtures, [:game, :login]

  alias Wallaby.WebdriverClient, as: Client

  test "user can set ships", %{session: session} do
    game = game_fixture()
    player1 = game.participants |> List.first()

    session =
      session
      |> do_login(player1.username)
      |> visit("/games/#{game.id}")

    Process.sleep(1000)

    elem =
      session
      |> find(Query.css("#cell-0-0"))

    {:ok, {x, y}} = Client.element_location(elem)

    {:ok, {x_start, y_start}} =
      session
      |> find(Query.css("#lobbycarrier"))
      |> Client.element_location()

    session
    |> find(Query.css("#lobbycarrier"))
    |> button_down()
    |> move_mouse_by(x - x_start, y - y_start)
    |> take_screenshot()
  end
end
