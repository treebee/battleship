defmodule BattleshipWeb.DuplicateUsernameTest do
  use BattleshipWeb.FeatureCase
  use Battleship.Fixtures, [:login]

  test "user cannot log in with already used username", %{session: session} do
    username = "hansi"
    do_login(session, username)

    {:ok, session2} = Wallaby.start_session()

    session2
    |> visit("/")
    |> fill_in(Query.css("#credentials_username"), with: username)
    |> take_screenshot()
    |> assert_has(Query.text("username already taken"))
  end
end
