defmodule BattleshipWeb.Components.GamesList do
  use BattleshipWeb, :live_component

  alias Battleship.Games

  @impl true
  def update(assigns, socket) do
    games = Games.get_game_list(assigns.username)
    {:ok, assign(socket, :games, games)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="">
      <h3 class="text-xl font-semibold text-white mb-8">Open Games</h3>
      <ul class="text-gray-200 text-lg">
          <%= for game <- @games do %>
            <%= live_redirect to: Routes.game_path(@socket, :index, game.id) do %>
              <li class="hover:text-blue-300 py-1">
                <%= String.slice(game.id, 0, 6) <> ": " <> render_participants(game.participants) %>
              </li>
            <% end %>
          <% end %>
      </ul>
    </div>
    """
  end

  defp render_participants([player1]), do: "#{player1.username} vs. "

  defp render_participants([player1, player2]), do: "#{player1.username} vs. #{player2.username}"
end
