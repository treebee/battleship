defmodule Battleship.ShipTest do
  use ExUnit.Case

  alias Battleship.Ship
  alias Battleship.Ships

  test "toggle direction" do
    ship = %Ship{name: "battleship", x: 4, y: 5, size: 4, direction: "x"}
    assert Ships.toggle_direction(ship) == %Ship{ship | direction: "y"}
  end

  test "ship was hit" do
    ship = %Ship{name: "battleship", x: 4, y: 5, size: 4, direction: "x"}
    assert Ships.is_hit?(ship, {5, 5})
  end

  test "shot missed ship" do
    ship = %Ship{name: "battleship", x: 4, y: 5, size: 4, direction: "x"}
    assert not Ships.is_hit?(ship, {3, 5})
  end
end
