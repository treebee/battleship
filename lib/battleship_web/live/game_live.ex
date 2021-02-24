defmodule BattleshipWeb.GameLive do
  use BattleshipWeb, :live_view
  alias Battleship.Field
  alias Battleship.Games
  alias Battleship.{Ship, Ships}
  alias Battleship.Participants
  alias BattleshipWeb.Presence

  @ships [
    %{name: "carrier", size: 5, draggable: true, direction: "y"},
    %{name: "battleship", size: 4, draggable: true, direction: "y"},
    %{name: "cruiser", size: 3, draggable: true, direction: "y"},
    %{name: "submarine", size: 3, draggable: true, direction: "y"},
    %{name: "destroyer", size: 2, draggable: true, direction: "y"}
  ]

  @impl true
  def mount(_params, session, socket) do
    current_user = Map.get(session, "username", nil)

    if connected?(socket) and current_user do
      Presence.track(self(), "users", current_user, %{})
    end

    {:ok, assign(socket, current_user: current_user, players: [])}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, socket |> assign(:game, Games.get_game!(id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: current_user}} = socket) do
    socket =
      Games.get_game!(id)
      |> assign_user_to_game(current_user, socket)
      |> prepare_player_info()

    {:noreply, assign(socket, :game, Games.get_game!(id))}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="container mt-12">
      <%= if @current_user do %>
        <%= if @game.state in [:started, :finished] do %>
          <%= live_component @socket, BattleshipWeb.Components.Game, game: @game, current_user: @current_user %>
        <% else %>
          <%= live_component @socket, BattleshipWeb.Components.GameLobby, ships_on_grid: @ships_on_grid, ships: @ships, ready: length(@player.ships) == 5 %>
        <% end %>
      <% else %>
        <%= live_component @socket, BattleshipWeb.Components.LoginComponent, id: "login", return_to: "/games/#{@game.id}" %>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event(
        "add_ship",
        %{"x" => x, "y" => y, "id" => id, "size" => size, "direction" => direction},
        socket
      ) do
    id = String.replace_leading(id, "lobby", "")

    ships_on_grid =
      socket.assigns.ships_on_grid
      |> Enum.filter(fn {_, %{name: name}} -> name != id end)
      |> Map.new()

    ship = %Ship{name: id, size: size, direction: direction, x: x, y: y}

    socket =
      if Field.placement_valid?(ship, ships_on_grid) do
        ships = update_ship(socket.assigns.ships, id, %{draggable: false})

        socket
        |> assign(:ships, ships)
        |> assign(:ships_on_grid, Map.put(ships_on_grid, {x, y}, ship))
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_direction", %{"x" => x, "y" => y}, socket) do
    {x, y} = {String.to_integer(x), String.to_integer(y)}

    ship =
      Map.get(socket.assigns.ships_on_grid, {x, y})
      |> Ships.toggle_direction()

    ship = %Ship{ship | x: x, y: y}

    ships = Map.delete(socket.assigns.ships_on_grid, {x, y})

    socket =
      if Field.placement_valid?(ship, ships) do
        socket
        |> assign(:ships_on_grid, Map.put(ships, {x, y}, ship))
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "ready",
        _,
        %{assigns: %{game: game, current_user: current_user, ships_on_grid: ships}} = socket
      ) do
    Participants.set_ships(Games.get_player(game, current_user), ships)

    game = Games.get_game!(game.id)

    game = if Games.ready?(game), do: Games.start_game!(game), else: game

    {:noreply,
     socket |> assign(:game, game) |> assign(:player, Games.get_player(game, current_user))}
  end

  @impl true
  def handle_event(
        "shoot",
        %{"x" => x, "y" => y},
        %{assigns: %{game: game, player: player}} = socket
      ) do
    socket =
      if Participants.their_turn?(player) do
        case Participants.shoot(player, {x, y}) do
          {:ok, player} ->
            Games.broadcast(game.id, "shoot")

            if Participants.has_won?(player) do
              Games.update_game(game, %{state: :finished})
              Games.broadcast(game.id, "game_finished")
            end

            socket |> assign(:game, Games.get_game!(game.id))

          {:error, error} ->
            IO.puts(:stderr, error)
            socket
        end
      else
        socket
      end

    {:noreply, socket}
  end

  defp update_ship(ships, id, params) do
    Enum.map(ships, fn ship ->
      case ship.name == id do
        true -> Map.merge(ship, params)
        false -> ship
      end
    end)
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    id = socket.assigns.game.id
    players = Presence.list("game:#{id}") |> Enum.map(fn {name, _} -> name end)
    {:noreply, assign(socket, players: players)}
  end

  @impl true
  def handle_info(%{event: "start_game"}, socket) do
    game = Games.get_game!(socket.assigns.game.id)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(%{event: "game_finished"}, socket) do
    game = Games.get_game!(socket.assigns.game.id)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(%{event: "shoot"}, socket) do
    game = Games.get_game!(socket.assigns.game.id)

    {:noreply,
     assign(socket, :game, game)
     |> assign(:player, Games.get_player(game, socket.assigns.current_user))}
  end

  defp assign_user_to_game(game, current_user, socket) do
    case Games.get_player(game, current_user) do
      nil ->
        case Games.add_player(game, current_user) do
          {:error, _error} ->
            socket
            |> put_flash(:error, "Game already has 2 players!")
            |> push_redirect(to: Routes.page_path(socket, :index))

          {:ok, player} ->
            track_user(game.id, player.username)
            socket |> assign(:player, player)
        end

      player ->
        track_user(game.id, current_user)
        socket |> assign(:player, player)
    end
  end

  def prepare_player_info(socket) do
    case Map.get(socket.assigns, :player) do
      nil ->
        socket

      player ->
        case player.ships do
          [] ->
            socket |> assign(:ships_on_grid, %{}) |> assign(:ships, @ships)

          ships ->
            ships_on_grid =
              ships |> Enum.map(fn ship -> {{ship.x, ship.y}, ship} end) |> Map.new()

            socket
            |> assign(:ships_on_grid, ships_on_grid)
            |> assign(:ready, length(socket.assigns.player.ships) == 5)
            |> assign(:ships, Enum.map(@ships, fn ship -> %{ship | draggable: false} end))
        end
    end
  end

  def track_user(game_id, username) do
    Games.subscribe(game_id)
    Presence.track(self(), "game:#{game_id}", username, %{})
  end
end
