defmodule BattleshipWeb.Components.Game do
  use BattleshipWeb, :live_component

  alias Battleship.Games
  alias Battleship.Participants

  @impl true
  def update(assigns, socket) do
    player_shots =
      assigns.player.shots |> Enum.map(&convert_shot/1) |> List.flatten() |> Map.new()

    opponent_shots =
      assigns.opponent.shots |> Enum.map(&convert_shot/1) |> List.flatten() |> Map.new()

    num_airstrikes =
      if assigns.player.num_airstrikes == nil do
        0
      else
        assigns.player.num_airstrikes
      end

    opponent_airstrikes =
      if assigns.opponent.num_airstrikes == nil do
        0
      else
        assigns.opponent.num_airstrikes
      end

    {:ok,
     assign(socket, assigns)
     |> assign(:player_shots, player_shots)
     |> assign(:opponent_shots, opponent_shots)
     |> assign(:num_airstrikes, num_airstrikes)
     |> assign(:opponent_airstrikes, opponent_airstrikes)}
  end

  @impl true
  def render(assigns) do
    ~L"""

      <%= if @game.state == :finished do %>
        <div class="container text-center my-16">
          <h1 class="font-semibold text-4xl text-white"><%= Games.winner(@game).username %> won the game!</h1>
        </div>
      <% end %>
      <div class="flex justify-center md:block">
        <div class="inline-block md:flex md:justify-between">
          <div>
            <%= live_component @socket, BattleshipWeb.Components.PlayerLabel, player: @player, active: @player.username == @next_player %>
            <div class="<%= if @player.username == @next_player do %>border-2 border-yellow-300 rounded-md shadow-lg<% end %>">
              <%= live_component @socket, BattleshipWeb.Components.Field,
                id: "player",
                ships: convert_ships(@player.ships),
                ready: true,
                shots: @opponent_shots,
                clickable: false,
                game_started: @game.state in [:started, :finished]
              %>
            </div>
            <div class="p-4">
              <%= live_component @socket, BattleshipWeb.Components.StatsLabel, text: "Hits", value: Participants.count_hits(@player) %>
              <%= live_component @socket, BattleshipWeb.Components.StatsLabel, text: "Airstrikes", value: @num_airstrikes %>
              <div
                id="airstrike"
                class="text-white"
                phx-window-keyup="switch_weapon">
                <div>
                  Currently selected weapon:
                  <span class="text-yellow-100 text-xl" data-testid="selected-weapon"><%= @weapon %></span>
                </div>
                <div>
                  Hit "space" to toggle weapons.
                </div>
              </div>
            </div>
          </div>
          <div>
            <%= live_component @socket, BattleshipWeb.Components.PlayerLabel, player: @opponent, active: @opponent.username == @next_player %>
            <div class="<%= if @opponent.username == @next_player do %>border-2 border-yellow-300 rounded-md shadow-lg<% end %>">
              <%= live_component @socket, BattleshipWeb.Components.Field,
                id: "opponent",
                ships: convert_ships(@opponent.ships),
                ready: true,
                is_opponent: true,
                shots: @player_shots,
                clickable: @game.state != :finished, weapon: @weapon,
                game_started: @game.state in [:started, :finished]
              %>
            </div>
            <div class="p-4">
              <%= live_component @socket, BattleshipWeb.Components.StatsLabel, text: "Hits", value: Participants.count_hits(@opponent) %>
              <%= live_component @socket, BattleshipWeb.Components.StatsLabel, text: "Airstrikes", value: @opponent_airstrikes %>
            </div>
          </div>
        </div>
      </div>
    """
  end

  defp convert_ships(ships) do
    ships |> Enum.map(fn ship -> {{ship.x, ship.y}, ship} end) |> Map.new()
  end

  defp convert_shot(%{type: :airstrike, strikes: strikes}) do
    strikes |> Enum.map(fn strike -> {{strike.x, strike.y}, strike} end)
  end

  defp convert_shot(shot), do: {{shot.x, shot.y}, shot}
end
