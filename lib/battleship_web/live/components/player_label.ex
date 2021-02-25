defmodule BattleshipWeb.Components.PlayerLabel do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <%= if @active do %>
        <h2 class="text-yellow-500 text-xl text-center my-2"><%= @player.username %></h2>
      <% else %>
        <h2 class="text-white text-xl text-center my-2"><%= @player.username %></h2>
      <% end %>
    """
  end
end
