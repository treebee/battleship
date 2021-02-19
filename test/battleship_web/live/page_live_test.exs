defmodule BattleshipWeb.PageLiveTest do
  use BattleshipWeb.ConnCase

  import Phoenix.LiveViewTest

  test "shows login when not authenticated", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert has_element?(view, "#credentials_username")
    assert not (html =~ "Welcome ")
  end

  test "authenticated user sees games and active users lists", %{conn: conn} do
    {:ok, _view, html} =
      live_isolated(conn, BattleshipWeb.PageLive, session: %{"username" => "patrick"})

    assert html =~ "Welcome patrick"
    assert html =~ "Open Games"
    assert html =~ "Active Users"
  end

  test "authenticated user can create new game", %{conn: conn} do
    {:ok, view, _html} =
      live_isolated(conn, BattleshipWeb.PageLive, session: %{"username" => "patrick"})

    {:error, {:live_redirect, %{kind: :push, to: game_link}}} =
      view
      |> element("button", "New Game")
      |> render_click()

    assert game_link =~ "/games/"
  end
end
