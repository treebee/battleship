defmodule BattleshipWeb.PageLive do
  use BattleshipWeb, :live_view

  alias Battleship.Games

  @impl true
  def mount(_params, %{"_csrf_token" => csrf_token} = session, socket) do
    {:ok,
     socket
     |> assign(:current_user, Map.get(session, "username"))
     |> assign(:csrf_token, csrf_token)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="mt-20 flex justify-center">
      <div class="max-w-64">
        <%= if @current_user do %>
        <button
          class="rounded-md py-1 px-2 bg-blue-400 font-semibold"
          phx-click="new_game"
        >New Game</button>
        <% else %>
        <%= live_component @socket, BattleshipWeb.Components.LoginComponent, id: "login", return_to: "/", csrf_token: @csrf_token %>
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
