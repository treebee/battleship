defmodule BattleshipWeb.Presence do
  use Phoenix.Presence,
    otp_app: :battleship,
    pubsub_server: Battleship.PubSub

  def subscribe() do
    BattleshipWeb.Endpoint.subscribe("users")
  end

  def list_users(topic \\ "users") do
    list(topic) |> Enum.map(fn {name, _} -> name end) |> Enum.sort()
  end

  def track_user(username, topic \\ "users") do
    track(self(), topic, username, %{})
  end
end
