defmodule BattleshipWeb.Components.HitCounter do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div class="text-2xl font-semibold text-yellow-300">
          Hits: <%= @num_hits %>
      </div>
    """
  end
end
