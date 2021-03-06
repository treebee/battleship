defmodule BattleshipWeb.PageLiveTest do
  use BattleshipWeb.ConnCase
  use BattleshipWeb.Fixtures, [:login]

  import Phoenix.LiveViewTest

  test "authenticated user can visit homepage", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> login(%{username: "patrick", return_to: "/"})
      |> live("/")

    assert html =~ "Welcome patrick"
    assert html =~ "Open Games"
    assert html =~ "Active Users"
  end

  test "shows login when not authenticated", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert has_element?(view, "#credentials_username")
    assert not (html =~ "Welcome ")
  end

  test "authenticated user can create new game", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> login(%{username: "patrick", return_to: "/"})
      |> live("/")

    {:error, {:live_redirect, %{kind: :push, to: game_link}}} =
      view
      |> element("form")
      |> render_submit()

    assert game_link =~ "/games/"
  end

  test "user can join game", %{conn: conn} do
    conn2 = login(conn, %{username: "player2", return_to: "/"})

    {:ok, view, _html} =
      conn
      |> login(%{username: "player1", return_to: "/"})
      |> live("/")

    {:error, {:live_redirect, %{kind: :push, to: game_link}}} =
      view
      |> element("form")
      |> render_submit()

    "/games/" <> game_id = game_link

    {:ok, view, _html} = live(conn2, "/")

    view
    |> element("#open-games > a:nth-child(1)")
    |> render_click()

    assert_redirected(view, "/games/#{game_id}")
  end

  test "user can create non-public games", %{conn: conn} do
    conn = login(conn, %{username: "player1", return_to: "/"})

    {:ok, view, _html} = live(conn, "/")

    {:error, {:live_redirect, %{kind: :push, to: game_link}}} =
      view
      |> form("#new-game-form", %{game: %{"secret" => true}})
      |> render_submit()

    {:ok, _view, html} = live(conn, "/")

    assert html =~ game_link

    {:ok, _view, html} = conn |> login(%{username: "player2", return_to: "/"}) |> live("/")
    assert not (html =~ game_link)
  end
end
