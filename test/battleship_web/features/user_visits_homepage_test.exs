defmodule BattleshipWeb.UserVisitsHomepageTest do
  use BattleshipWeb.FeatureCase
  use Battleship.Fixtures, [:login]

  test "user can visit homepage", %{session: session} do
    session
    |> visit("/")
    |> assert_has(Query.css("a", text: "Battleship"))
  end

  test "user can log in", %{session: session} do
    session
    |> do_login("patrick")
    |> assert_has(Query.text("Welcome patrick"))
  end
end
