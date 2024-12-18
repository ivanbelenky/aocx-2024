defmodule WarehouseWoes do
  def parse_input(input) do
    [grid, directions] = String.split(input, "\n\n")
    grid = String.split(grid, "\n") |> Enum.map(&(to_charlist(&1)))
    directions = String.split(directions, "\n") |> Enum.map(&(to_charlist(&1))) |> List.flatten()
    {grid, directions}
  end

  def dr(?>), do: {1, 0}
  def dr(?<), do: {-1, 0}
  def dr(?^), do: {0, -1}
  def dr(?v), do: {0, 1}

  def overflow(pos) do
    {i, j} = pos
    i < 0 or j < 0 or i > 49 or j > 49 # hardcoded
  end

  def grid_val(pos, positions, wall_positions) do
    case MapSet.member?(positions, pos) do
      true -> ?O
      false ->
        case overflow(pos) do
          true -> ?#
          false -> if MapSet.member?(wall_positions, pos), do: ?#, else: ?.
        end
    end
  end

  def _step(_, _, ?#, _, _, _), do: :nothing
  def _step(_, to_move, ?., _, _, _), do: to_move
  def _step(pos, to_move, dir, box_positions, wall_positions, dr) when dir in [?>, ?<, ?^, ?v, ?O] do
    {dx, dy} = dr
    {i, j} = pos
    new_pos = {i+dx, j+dy}
    to_move = to_move ++ [pos]
    _step(new_pos, to_move, grid_val(new_pos, box_positions, wall_positions), box_positions, wall_positions, dr)
  end

  def transition(start_pos, dir, box_positions, wall_positions) do
    to_move = []
    dr = {dx, dy} = dr(dir)
    to_move = _step(start_pos, to_move, dir, box_positions, wall_positions, dr)
    {x, y} = start_pos
    cond do
      to_move == :nothing -> {start_pos, box_positions}
      length(to_move) == 1 -> {{x+dx, y+dy}, box_positions}
      length(to_move) > 1 ->
        moving = MapSet.difference(box_positions, MapSet.new(to_move))
        new_moved = Enum.map(to_move, fn {i, j} -> {i+dx, j+dy} end)
        [robot_pos | new_box_positions] = new_moved
        box_positions = MapSet.union(moving, MapSet.new(new_box_positions))
        {robot_pos, box_positions}
    end
  end

  def get_positions_of_char(grid, char) do
    Enum.reduce(Enum.with_index(grid), MapSet.new(), fn {row, j}, acc ->
      new_acc = Enum.reduce(Enum.with_index(row), MapSet.new(), fn {val, i}, val_acc ->
        case val == char do
          true -> MapSet.put(val_acc, {i, j})
          false -> val_acc
        end
      end)
      MapSet.union(acc, new_acc)
    end)
  end

  def apply_directions(start_pos, directions, box_positions, wall_positions) do
    Enum.reduce(directions, {start_pos, box_positions}, fn dir, {pos, box_pos} ->
      transition(pos, dir, box_pos, wall_positions)
    end)
  end

  def gps_coordinates_sum(box_pos) do
    Enum.map(box_pos, fn {i, j} -> i+100*j end) |> Enum.sum()
  end

end


# import WarehouseWoes
input = ~S"########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<"

#{grid, directions} = parse_input(input)
#box_positions = get_positions_of_char(grid, ?O)
#wall_positions = get_positions_of_char(grid, ?#)
#transition({2,2}, ?>, box_positions, wall_positions)
