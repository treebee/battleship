defmodule BattleshipWeb.Components.GameLobby do
  use BattleshipWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="flex justify-center">
        <%= live_component @socket, BattleshipWeb.Components.Field, id: "player", ships: @assigned_ships, ready: @ready, clickable: false %>
        <hr class="mx-4" />
        <div class="flex flex-col justify-between">
          <button
            class="my-2 py-1 py-2 bg-blue-500 font-semibold disabled:opacity-20"
            <%= if @ready or length(Map.keys(@assigned_ships)) != 5 do %>disabled="disabled"<% end %>
            phx-click="ready"
          >Ready</button>
          <div class="w-64 h-64 flex">
            <%= for %{name: name, size: size, draggable: draggable} <- Enum.sort_by(@ships, &(&1.size), :desc) do %>
              <%= live_component @socket, BattleshipWeb.Components.Ship, id: "lobby" <> name, size: size, draggable: draggable, direction: "y" %>
            <% end %>
          </div>
        </div>
      </div>
      <div class="flex justify-center container mt-8 text-lg text-gray-200">
        <div>
          <p>Drag the ship on to the grid.<p>
          <p>Change between horizontal/vertical by clicking on ship once on grid.</p>
        </div>
      </div>
    """
  end
end
