defmodule BattleshipWeb.Presence do
  use Phoenix.Presence,
    otp_app: :battleship,
    pubsub_server: Battleship.PubSub

  def list_users(topic \\ "users") do
    list(topic) |> Enum.map(fn {name, _} -> name end)
  end
end
