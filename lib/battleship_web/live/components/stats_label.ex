defmodule BattleshipWeb.Components.StatsLabel do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div class="text-2xl font-semibold text-yellow-300">
          <%= @text %>: <%= @value %>
      </div>
    """
  end
end
