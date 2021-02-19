defmodule Battleship.FieldTest do
  use ExUnit.Case

  alias Battleship.Field
  alias Battleship.Ship

  test "ship can be placed" do
    ship = %Ship{name: "battleship", x: 4, y: 5, size: 4, direction: "x"}
    assert Field.placement_valid?(ship, %{})
  end

  test "ship can not be placed" do
    ship = %Ship{name: "battleship", x: 7, y: 5, size: 4, direction: "x"}
    assert not Field.placement_valid?(ship, %{})
  end

  test "ship collides with other ship" do
    ship = %Ship{name: "battleship", x: 7, y: 5, size: 4, direction: "y"}
    ships = %{{7, 8} => %Ship{name: "destroyer", x: 7, y: 8, size: 2, direction: "x"}}
    assert not Field.placement_valid?(ship, ships)
  end
end
