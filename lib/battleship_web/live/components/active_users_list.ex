defmodule BattleshipWeb.Components.ActiveUsersList do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="">
      <h3 class="text-xl font-semibold text-white mb-8">Active Users</h3>
      <ul
        class="text-gray-200 text-lg"
        >
        <%= for user <- @users do %>
          <li id="user-<%= user %>"><%= user %></li>
        <% end %>
      </ul>
    </div>
    """
  end
end
