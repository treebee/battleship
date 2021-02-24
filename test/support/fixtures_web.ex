defmodule BattleshipWeb.Fixtures do
  @moduledoc """
  Defines fixtures for web related things that can be used in tests,
  like login with the current connection.

  This module can be used with a list of fixtures to apply as parameter:

    use BattleshipWeb.Fixtures, [:login]
  """
  def login() do
    alias BattleshipWeb.Router.Helpers, as: Routes

    quote do
      def login(conn, credentials) do
        post(conn, Routes.login_path(conn, :login), credentials: credentials)
      end
    end
  end

  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
