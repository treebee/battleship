defmodule BattleshipWeb.Components.HitCounter do
  use BattleshipWeb, :live_component

  @impl true
  def update(%{shots: shots}, socket) do
    num_hits = Enum.count(shots, fn shot -> shot.hit end)
    {:ok, assign(socket, :num_hits, num_hits)}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div class="text-center text-2xl font-semibold text-yellow-300">
          Hits: <%= @num_hits %>
      </div>
    """
  end
end
