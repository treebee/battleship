defmodule BattleshipWeb.Components.LoginComponent do
  use BattleshipWeb, :live_component

  alias BattleshipWeb.Presence

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :error, nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <%= form_for :credentials,
          Routes.login_path(BattleshipWeb.Endpoint, :login),
          [phx_change: :validate, phx_target: @myself],
          fn f-> %>
        <%= text_input f, :username, class: "p-1" %>
        <%= hidden_input f, :return_to, value: @return_to %>
        <%= submit "login",
            class: "py-1 px-4 bg-gray-700 mx-2 rounded-md text-white font-semibold disabled:opacity-50",
            disabled: @error != nil %>
        <%= render_error f, :username, @error %>
      <% end %>
    """
  end

  @impl true
  def handle_event("validate", %{"credentials" => %{"username" => username}} = _params, socket) do
    cond do
      username in Presence.list_users() ->
        {:noreply, assign(socket, :error, "username already taken")}

      true ->
        {:noreply, socket}
    end
  end
end
