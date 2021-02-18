defmodule BattleshipWeb.UserVisitsHomepageTest do
  use BattleshipWeb.FeatureCase, async: true

  test "user can visit homepage", %{session: session} do
    session
    |> visit("/")
    |> assert_has(Query.css("a", text: "Battleship"))
  end
end
