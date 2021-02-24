defmodule BattleshipWeb.PageLive do
  use BattleshipWeb, :live_view

  alias Battleship.Games
  alias BattleshipWeb.Presence

  @impl true
  def mount(_params, session, socket) do
    username = Map.get(session, "username")
    Presence.track_user(username)

    if connected?(socket) do
      Presence.subscribe()
      Games.subscribe()
    end

    games = Games.get_game_list(username)

    {:ok,
     socket
     |> assign(:current_user, username)
     |> assign(:games, games)
     |> assign(:active_users, Presence.list_users()), temporary_assigns: [games: []]}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="mt-10 mx-4">
      <%= if @current_user do %>
      <div class="p-5 rounded rounded-md bg-gradient-to-br from-gray-900 to-gray-800 shadow-lg">
        <h1 class="text-2xl text-blue-200 mb-2">
          Welcome <%= @current_user %>
        </h1>
        <p class="text-lg text-gray-100">
          Join one of the open games or create a new one to play with a friend.
        </p>
        <div class="py-2 mt-5">
          <button
            class="rounded-md py-1 px-2 border-2 border-blue-200 hover:bg-blue-400 font-semibold text-white"
            phx-click="new_game"
          >New Game</button>
        </div>
      </div>
      <div class="flex justify-between p-5 bg-gradient-to-br from-gray-900 to-gray-800 shadow-lg mt-5 rounded rounded-md">
        <div class="flex">
          <%= live_component @socket, BattleshipWeb.Components.GamesList, username: @current_user, games: @games %>
        </div>
          <%= live_component @socket, BattleshipWeb.Components.ActiveUsersList, users: @active_users %>
      <% else %>
        <div class="flex justify-center">
          <%= live_component @socket, BattleshipWeb.Components.LoginComponent, id: "login", return_to: "/" %>
      <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("new_game", _params, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, game} = Games.create_game()
    Games.add_player(game, current_user)

    socket =
      socket
      |> push_redirect(to: Routes.game_path(socket, :index, game.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "game_created", payload: game}, socket) do
    {:noreply, update(socket, :games, fn games -> [game | games] end)}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", topic: "users"},
        socket
      ) do
    {:noreply, assign(socket, :active_users, Presence.list_users())}
  end
end
