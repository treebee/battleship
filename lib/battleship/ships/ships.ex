defmodule Battleship.Ships do
  alias Battleship.Ship

  def cells(%Ship{} = ship) do
    case ship.direction do
      "x" -> Enum.map(0..(ship.size - 1), fn i -> {ship.x + i, ship.y} end)
      "y" -> Enum.map(0..(ship.size - 1), fn i -> {ship.x, ship.y + i} end)
    end
  end

  def toggle_direction("y"), do: "x"
  def toggle_direction("x"), do: "y"

  def toggle_direction(%Battleship.Ship{} = ship) do
    %Battleship.Ship{ship | direction: toggle_direction(ship.direction)}
  end

  def is_hit?(ship, {x, y}) do
    {x, y} in cells(ship)
  end
end
