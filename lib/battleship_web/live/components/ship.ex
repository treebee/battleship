defmodule BattleshipWeb.Components.Ship do
  use BattleshipWeb, :live_component

  @defaults %{
    draggable: true,
    x: -1,
    y: -1,
    direction: "y"
  }

  @impl true
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl true
  def update(assigns, socket) do
    in_grid = not String.starts_with?(assigns.name, "lobby")
    {:ok, socket |> assign(assigns) |> assign(:in_grid, in_grid)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div
    >
      <div
        draggable="<%= @draggable %>"
        ondragstart="dragStart(event)"
        class='bg-green-400 cursor-move grid <%= if @direction == "y" do %>grid-flow-row<% else %>grid-flow-col<% end %> gap-1 <%= if !@draggable and !@in_grid do %>opacity-50<% end %> <%= if @in_grid do %>absolute z-10<% else %>mx-1<% end %>'
        id="<%= @name %>"
        phx-value-x="<%= @x %>"
        phx-value-y="<%= @y %>"
        phx-value-size="<%= @size %>"
        phx-value-direction="<%= @direction %>"
        <%= if @in_grid do %>
        phx-click="toggle_direction"
        <% end %>
      >
        <%= for _ <- 1..@size do %>
        <div class="w-8 h-8 border-green-600 border-2"></div>
        <% end %>
      </div>
    </div>
    """
  end
end
