defmodule BattleshipWeb.Components.ActiveUsersList do
  use BattleshipWeb, :live_component

  alias BattleshipWeb.Presence

  @impl true
  def update(_assigns, socket) do
    {:ok, assign(socket, :users, Presence.list_users())}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="">
      <h3 class="text-xl font-semibold text-white mb-8">Active Users</h3>
      <ul class="text-gray-200 text-lg">
        <%= for user <- @users do %>
          <li><%= user %></li>
        <% end %>
      </ul>
    </div>
    """
  end
end
