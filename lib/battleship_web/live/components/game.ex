defmodule BattleshipWeb.Components.Game do
  use BattleshipWeb, :live_component

  alias Battleship.Games

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    player = Games.get_player(assigns.game, assigns.current_user)
    opponent = Games.get_opponent(assigns.game, assigns.current_user)

    player_shots = player.shots |> Enum.map(fn shot -> {{shot.x, shot.y}, shot} end) |> Map.new()

    opponent_shots =
      opponent.shots |> Enum.map(fn shot -> {{shot.x, shot.y}, shot} end) |> Map.new()

    {:ok,
     assign(socket, assigns)
     |> assign(:player, player)
     |> assign(:opponent, opponent)
     |> assign(:player_shots, player_shots)
     |> assign(:opponent_shots, opponent_shots)}
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
            <%= live_component @socket, BattleshipWeb.Components.PlayerLabel, player: @player %>
            <%= live_component @socket, BattleshipWeb.Components.Field, id: "player", ships: convert_ships(@player.ships), ready: true, shots: @opponent_shots, clickable: false %>
          </div>
          <div>
            <%= live_component @socket, BattleshipWeb.Components.PlayerLabel, player: @opponent %>
            <%= live_component @socket, BattleshipWeb.Components.Field,
              id: "opponent",
              ships: convert_ships(@opponent.ships),
              ready: true,
              is_opponent: true,
              shots: @player_shots,
              clickable: @game.state != :finished %>
          </div>
        </div>
      </div>
    """
  end

  defp convert_ships(ships) do
    ships |> Enum.map(fn ship -> {{ship.x, ship.y}, ship} end) |> Map.new()
  end
end