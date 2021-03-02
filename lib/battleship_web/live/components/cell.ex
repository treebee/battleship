defmodule BattleshipWeb.Components.Cell do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div
      class="bg-blue-800 w-8 h-8 relative"
      phx-value-x="<%= @x %>"
      phx-value-y="<%= @y %>"
      <%= if @clickable do %>
      id="cell-<%= @x %>-<%= @y %>"
      phx-click="shoot"
      phx-value-type="<%= @weapon %>"
      style="cursor: crosshair"
      onmouseover="highlightCells(event, { weapon: '<%= @weapon %>'})"
      <% else %>
      <%= if not @game_started do %>
      id="cell-<%= @x %>-<%= @y %>"
      phx-hook="Drag"
      <% end %>
      <% end %>
    >
      <%= if @ship do %>
        <%= render_block(@inner_block, ship: @ship) %>
      <% end %>
      <%= if @shot != nil do %>
      <div class="w-4 h-4 rounded-full <%= if @shot.hit do %>bg-red-400<% else %>bg-gray-800<% end %> m-2 z-20 opacity-100"></div>
      <% end %>
    </div>
    """
  end
end
