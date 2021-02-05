defmodule BattleshipWeb.LoginController do
  use BattleshipWeb, :controller

  alias BattleshipWeb.Presence

  def login(conn, %{"credentials" => %{"username" => username, "return_to" => return_to}}) do
    case username in Presence.list_users() do
      true ->
        conn
        |> put_flash(:error, "Username #{username} already taken!")
        |> redirect(to: return_to)

      _ ->
        conn |> put_session(:username, username) |> redirect(to: return_to)
    end
  end
end
