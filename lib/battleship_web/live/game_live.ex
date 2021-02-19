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
    Presence.track(self(), "users", current_user, %{})
    {:ok, assign(socket, current_user: current_user, players: [])}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, socket |> assign(:game, Games.get_game!(id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: current_user}} = socket) do
    game = Games.get_game!(id)

    socket =
      case Games.get_player(game, current_user) do
        nil ->
          case game.participants |> Enum.map(fn p -> p.username end) do
            [_player1, _player2] ->
              socket
              |> put_flash(:error, "Game already has 2 players!")
              |> push_redirect(to: Routes.page_path(socket, :index))

            _ ->
              {:ok, player} = Games.add_player(game, current_user)
              track_user(game.id, current_user)
              socket |> assign(:game, Games.get_game!(id)) |> assign(:player, player)
          end

        player ->
          track_user(game.id, current_user)
          socket |> assign(:player, player)
      end

    socket =
      case Map.get(socket.assigns, :player) do
        nil ->
          socket

        player ->
          case player.ships do
            [] ->
              socket |> assign(:assigned_ships, %{}) |> assign(:ships, @ships)

            ships ->
              assigned_ships =
                ships |> Enum.map(fn ship -> {{ship.x, ship.y}, ship} end) |> Map.new()

              socket
              |> assign(:assigned_ships, assigned_ships)
              |> assign(:ready, length(socket.assigns.player.ships) == 5)
              |> assign(:ships, Enum.map(@ships, fn ship -> %{ship | draggable: false} end))
          end
      end

    {:noreply,
     socket
     |> assign(:game, game)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="container mt-12">
      <%= if @current_user do %>
        <%= if @game.state in [:started, :finished] do %>
          <%= live_component @socket, BattleshipWeb.Components.Game, game: @game, current_user: @current_user %>
        <% else %>
          <%= live_component @socket, BattleshipWeb.Components.GameLobby, assigned_ships: @assigned_ships, ships: @ships, ready: length(@player.ships) == 5 %>
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

    assigned_ships =
      case Enum.find(socket.assigns.assigned_ships, fn {_, %{name: name}} -> name == id end) do
        {{a, b}, _} -> Map.delete(socket.assigns.assigned_ships, {a, b})
        _ -> socket.assigns.assigned_ships
      end

    ship = %Ship{name: id, size: size, direction: direction, x: x, y: y}

    socket =
      case Field.placement_valid?(ship, assigned_ships) do
        true ->
          ships = update_ship(socket.assigns.ships, id, %{draggable: false})

          socket
          |> assign(:ships, ships)
          |> assign(:assigned_ships, Map.put(assigned_ships, {x, y}, ship))

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_direction", %{"x" => x, "y" => y}, socket) do
    {x, y} = {String.to_integer(x), String.to_integer(y)}

    ship =
      Map.get(socket.assigns.assigned_ships, {x, y})
      |> Ships.toggle_direction()

    ship = %Ship{ship | x: x, y: y}

    ships = Map.delete(socket.assigns.assigned_ships, {x, y})

    socket =
      case Field.placement_valid?(ship, ships) do
        true ->
          socket
          |> assign(:assigned_ships, Map.put(ships, {x, y}, ship))

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "ready",
        _,
        %{assigns: %{game: game, current_user: current_user, assigned_ships: ships}} = socket
      ) do
    Games.set_ships(Games.get_player(game, current_user), ships)

    game = Games.get_game!(game.id)

    IO.inspect(game.participants)
    IO.inspect(Games.ready?(game))
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
      case Participants.their_turn?(player) do
        true ->
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

        false ->
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

  def track_user(game_id, username) do
    Games.subscribe(game_id)
    Presence.track(self(), "game:#{game_id}", username, %{})
  end
end
