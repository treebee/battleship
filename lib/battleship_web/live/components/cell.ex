defmodule BattleshipWeb.Components.Cell do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div
      class="bg-blue-800 border-blue-900 text-white text-center text-xs w-8 h-8 relative"
      phx-value-x="<%= @x %>"
      phx-value-y="<%= @y %>"
      phx-value-type="<%= :torpedo %>"
      <%= if @clickable do %>
      style="cursor: crosshair"
      phx-click="shoot"
      id="cell-<%= @x %>-<%= @y %>"
      <% else %>
      phx-hook="Drag"
      ondrop="dragHook.dropShip(event, <%= @x %>, <%= @y %>)"
      ondragover="event.currentTarget.classList.add('bg-blue-900')"
      ondragleave="event.currentTarget.classList.remove('bg-blue-900')"
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
