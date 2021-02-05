defmodule BattleshipWeb.Components.Field do
  use BattleshipWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket, :ships, [])
     |> assign(:is_opponent, false)
     |> assign(:shots, %{})
     |> assign(:clickable, false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :clickable,
       Map.get(assigns, :clickable, true) and Map.get(assigns, :is_opponent, false)
     )}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="p-2 bg-blue-600 rounded-md">
      <div class="grid grid-cols-10 gap-1">
        <%= for y <- 0..9 do %>
          <%= for x <- 0..9 do %>
            <%= live_component @socket, BattleshipWeb.Components.Cell, id: {@id, x, y}, x: x, y: y, ship: Map.get(@ships, {x, y}), shot: Map.get(@shots, {x, y}), clickable: @clickable do %>
            <%= if not @is_opponent do %>
              <%= live_component @socket, BattleshipWeb.Components.Ship,
                  id: @ship.name,
                  draggable: not @ready,
                  x: x,
                  y: y,
                  size: @ship.size,
                  direction: @ship.direction %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
