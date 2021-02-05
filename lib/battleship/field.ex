defmodule Battleship.Field do
  alias Battleship.Ship
  alias Battleship.Ships

  @max_x 9
  @max_y 9

  def placement_valid(%Ship{x: x, y: _y, size: size, direction: "x"}, _ships)
      when x + size > @max_x + 1,
      do: false

  def placement_valid(%Ship{x: _x, y: y, size: size, direction: "y"}, _ships)
      when y + size > @max_y + 1,
      do: false

  def placement_valid(%Ship{} = ship, ships) do
    occupied_cells =
      ships
      |> Enum.map(fn {{a, b}, %{direction: direction, size: size}} ->
        Ships.cells(%Ship{x: a, y: b, size: size, direction: direction})
      end)
      |> List.flatten()
      |> MapSet.new()

    current_ship_cells = Ships.cells(ship) |> MapSet.new()
    MapSet.intersection(occupied_cells, current_ship_cells) == MapSet.new()
  end
end
