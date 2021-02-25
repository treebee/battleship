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

    {:ok, assign(socket, current_user: current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, socket |> assign(:game, Games.get_game!(id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: current_user}} = socket) do
    game = Games.get_game!(id)
    socket = assign(socket, :game, game)

    socket =
      socket
      |> assign_user_to_game(current_user)
      |> assign_opponent()
      |> determine_next_player()
      |> prepare_player_info()

    Games.subscribe(id)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="container mt-12">
      <%= if @current_user do %>
        <%= if @game.state in [:started, :finished] do %>
          <%= live_component @socket, BattleshipWeb.Components.Game, game: @game, player: @player, opponent: @opponent, next_player: @next_player %>
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

    player = Games.get_player(game, current_user)
    opponent = Participants.get_opponent(player)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:player, player)
     |> assign(:opponent, opponent)}
  end

  @impl true
  def handle_event(
        "shoot",
        %{"x" => x, "y" => y},
        %{assigns: %{game: game, player: player, opponent: opponent}} = socket
      ) do
    socket =
      if Participants.their_turn?(player) do
        case Participants.shoot(player, {x, y}, opponent) do
          {:ok, player} ->
            [shot | _shots] = player.shots
            Games.broadcast(game.id, "shoot", %{"username" => player.username, "shot" => shot})

            if Participants.has_won?(player) do
              Games.update_game(game, %{state: :finished})
              Games.broadcast(game.id, "game_finished")
            end

            socket |> assign(:player, player)

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
  def handle_info(%{event: "shoot", payload: %{"username" => shooter, "shot" => shot}}, socket) do
    socket =
      if socket.assigns.player.username != shooter do
        assign(socket, :opponent, %{
          socket.assigns.opponent
          | shots: [shot | socket.assigns.opponent.shots]
        })
      else
        socket
      end

    {:noreply, socket |> toggle_next_player()}
  end

  defp assign_user_to_game(%{assigns: %{game: game}} = socket, current_user) do
    case Games.get_player(game, current_user) do
      nil ->
        case Games.add_player(game, current_user) do
          {:error, _error} ->
            socket
            |> put_flash(:error, "Game already has 2 players!")
            |> push_redirect(to: Routes.page_path(socket, :index))

          {:ok, player} ->
            socket |> assign(:player, player) |> assign(:game, Games.get_game!(game.id))
        end

      player ->
        socket |> assign(:player, player)
    end
  end

  defp assign_opponent(%{assigns: %{player: player}} = socket) do
    assign(socket, :opponent, Participants.get_opponent(player))
  end

  defp assign_opponent(socket), do: socket

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

  defp determine_next_player(%{assigns: %{player: player, opponent: opponent}} = socket) do
    if Participants.their_turn?(player) do
      assign(socket, :next_player, player.username)
    else
      assign(socket, :next_player, opponent.username)
    end
  end

  defp determine_next_player(socket), do: socket

  defp toggle_next_player(
         %{
           assigns: %{
             next_player: next_player,
             player: %{username: next_player},
             opponent: opponent
           }
         } = socket
       ) do
    assign(socket, :next_player, opponent.username)
  end

  defp toggle_next_player(
         %{
           assigns: %{
             next_player: next_player,
             player: player,
             opponent: %{username: next_player}
           }
         } = socket
       ) do
    assign(socket, :next_player, player.username)
  end
end
