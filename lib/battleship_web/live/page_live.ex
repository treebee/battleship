defmodule BattleshipWeb.PageLive do
  use BattleshipWeb, :live_view

  alias Battleship.Games
  alias BattleshipWeb.Presence

  @impl true
  def mount(_params, session, socket) do
    username = Map.get(session, "username")
    Presence.track_user(username)

    {:ok,
     socket
     |> assign(:current_user, username)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="mt-20">
      <%= if @current_user do %>
      <h1 class="text-2xl text-blue-200 mb-5">Welcome, <%= @current_user %></h1>
        <div class="flex justify-between">
          <div class="flex">
            <%= live_component @socket, BattleshipWeb.Components.GamesList, id: "games-list", username: @current_user %>
            <div class="py-2">
              <button
                class="rounded-md py-1 px-2 border-2 border-blue-200 hover:bg-blue-400 font-semibold text-white"
                phx-click="new_game"
              >New Game</button>
            </div>
          </div>
          <%= live_component @socket, BattleshipWeb.Components.ActiveUsersList, id: "active-users" %>
        <% else %>
          <div class="flex justify-center">
          <%= live_component @socket, BattleshipWeb.Components.LoginComponent, id: "login", return_to: "/" %>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("new_game", _params, socket) do
    {:ok, game} = Games.create_game(%{player_1_name: socket.assigns.current_user})

    socket =
      socket
      |> push_redirect(to: Routes.game_path(socket, :index, game.id))

    {:noreply, socket}
  end
end
