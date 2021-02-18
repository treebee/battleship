defmodule BattleshipWeb.PageLiveTest do
  use BattleshipWeb.ConnCase

  import Phoenix.LiveViewTest

  test "shows login when not authenticated", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert has_element?(view, "#credentials_username")
    assert not (html =~ "Welcome ")
  end
end
