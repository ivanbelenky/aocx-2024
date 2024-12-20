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

  def overflow(pos, overflow_size \\ 49) do
    {i, j} = pos
    i < 0 or j < 0 or i > overflow_size or j > overflow_size
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

  def grid_val2(pos, left_box_pos, right_box_pos, wall_positions) do
    cond do
      MapSet.member?(left_box_pos, pos) -> ?[
      MapSet.member?(right_box_pos, pos) -> ?]
      MapSet.member?(wall_positions, pos) -> ?#
      overflow(pos, 99) -> ?#
      true -> ?.
    end

  end

  def _step2(_, _, ?#, _, _, _, _), do: [:nothing]
  def _step2(_, to_move, ?., _, _, _, _), do: to_move
  def _step2(pos, to_move, box_side, lbp, rbp, wp, {dx, 0}) when box_side in [?[, ?]] do
    {i, j} = pos
    pos = case box_side do
      ?[ -> {i, j, :left}
      ?] -> {i, j, :right}
    end
    to_move = to_move ++ [pos]
    _step2({i+dx, j}, to_move, grid_val2({i+dx, j}, lbp, rbp, wp), lbp, rbp, wp, {dx, 0})
  end

  def _step2(pos, to_move, box_side, lbp, rbp, wp, {0, dy}) when box_side in [?[, ?]] and dy in [-1, 1] do
    {i, j} = pos
    {{lx, ly}, {rx, ry}} = case box_side do
      ?[ -> {pos, {i+1, j}}
      ?] -> {{i-1, j}, pos}
    end

    to_move = if Enum.member?(to_move, {lx, ly, :left}) do
      to_move
    else
      to_move = to_move ++ [{lx, ly, :left}]
      new_left = {lx, ly+dy}
      to_move_left = _step2(new_left, to_move, grid_val2(new_left, lbp, rbp, wp), lbp, rbp, wp, {0, dy})
      to_move ++ to_move_left
    end

    if Enum.member?(to_move, :nothing) do
      [:nothing]
    else
      to_move = if Enum.member?(to_move, {rx, ry, :right}) do
        to_move
      else
        to_move = to_move ++ [{rx, ry, :right}]
        new_right = {rx, ry+dy}
        to_move_right = _step2(new_right, to_move, grid_val2(new_right, lbp, rbp, wp), lbp, rbp, wp, {0, dy})
        if Enum.member?(to_move_right, :nothing) do
          [:nothing]
        else
          to_move ++ to_move_right
        end
      end
      to_move
    end
  end


  def _step2(pos, to_move, dir, lbp, rbp, wp, dr) when dir in [?>, ?<, ?^, ?v] do
    {dx, dy} = dr
    {i, j} = pos
    new_pos = {i+dx, j+dy}
    to_move = to_move ++ [pos]
    _step2(new_pos, to_move, grid_val2(new_pos, lbp, rbp, wp), lbp, rbp, wp, dr)
  end

  def double_grid(grid) do
    Enum.map(grid, fn row ->
      Enum.map(row, fn c ->
        case c do
          ?. -> [?., ?.]
          ?# -> [?#, ?#]
          ?O -> [?[, ?]]
          ?@ -> [?@, ?.]
        end
      end) |> List.flatten()
    end)
  end

  def transition2(start_pos, dir, lbp, rbp, wall_positions) do
    dr = {dx, dy} = dr(dir)
    to_move = _step2(start_pos, [], dir, lbp, rbp, wall_positions, dr)
    {x, y} = start_pos
    cond do
      Enum.member?(to_move, :nothing) -> {start_pos, lbp, rbp}
      to_move == :nothing -> {start_pos, lbp, rbp}
      length(to_move) == 1 -> {{x+dx, y+dy}, lbp, rbp}
      length(to_move) > 1 ->
        [_ | rest] = to_move

        {lefties, righties} = Enum.reduce(rest, {MapSet.new(), MapSet.new()}, fn r, {acc_l, acc_r} ->
          case r do
            {px, py,:left} -> {MapSet.put(acc_l, {px, py}), acc_r}
            {px, py, :right} -> {acc_l, MapSet.put(acc_r, {px, py})}
            {_px, _py} -> {acc_l, acc_r}
          end
        end)

        moving_l = MapSet.difference(lbp, MapSet.new(lefties))
        moving_r = MapSet.difference(rbp, MapSet.new(righties))
        new_moved_l = MapSet.new(Enum.map(lefties, fn {i, j} -> {i+dx, j+dy} end))
        new_moved_r = MapSet.new(Enum.map(righties, fn {i, j} -> {i+dx, j+dy} end))
        new_lbp =  MapSet.union(moving_l, new_moved_l)
        new_rbp =  MapSet.union(moving_r, new_moved_r)
        new_pos = {x+dx, y+dy}

        {new_pos, new_lbp, new_rbp}
    end
  end

  def transform_to_grid({pos, lbp, rbp, wp}, {height, width}) do
    grid = for _ <- 0..(height-1), do: for _ <- 0..(width-1), do: ?.

    grid = Enum.reduce(lbp, grid, fn {i, j}, acc ->
      List.update_at(acc, j, fn row -> List.replace_at(row, i, ?[) end)
    end)

    grid = Enum.reduce(rbp, grid, fn {i, j}, acc ->
      List.update_at(acc, j, fn row -> List.replace_at(row, i, ?]) end)
    end)

    grid = Enum.reduce(wp, grid, fn {i, j}, acc ->
      List.update_at(acc, j, fn row -> List.replace_at(row, i, ?#) end)
    end)

    {x, y} = pos
    grid = List.update_at(grid, y, fn row -> List.replace_at(row, x, ?@) end)

    grid
  end



end


#import WarehouseWoes
#input = ~S"########
##..O.O.#
###@.O..#
##...O..#
##.#.O..#
##...O..#
##......#
#########
#
#<^^>>>vv<v>>v<<"

#{grid, directions} = parse_input(input)
#box_positions = get_positions_of_char(grid, ?O)
#wall_positions = get_positions_of_char(grid, ?#)
#transition({2,2}, ?>, box_positions, wall_positions)

# import WarehouseWoes
# input = File.read!("./lib/input/warehouse_woes.txt")
# {grid, directions} = parse_input(input)
# dgrid = double_grid(grid)
# lbp = get_positions_of_char(dgrid, ?[)
# rbp = get_positions_of_char(dgrid, ?])
# wp  = get_positions_of_char(dgrid, ?#)
# WarehouseWoes._step2({4, 2}, [], ?>, lbp, rbp, wp, {1, 0})
# Enum.map(dgrid, &IO.puts(&1))
# {fp, flbp, frbp} = Enum.reduce(Enum.with_index(directions), {{48,24}, lbp, rbp}, fn {dir, idx}, {new_pos, new_lbp, new_rbp} ->
# {np, nlbp, nrbp} = transition2(new_pos, dir, new_lbp, new_rbp, wp)
# IO.puts(idx/length(directions))
# #Enum.map(transform_to_grid({np, nlbp, nrbp, wp}, {50, 100}), &IO.puts(&1))
# {np, nlbp, nrbp}
# end)
# Enum.map(flbp, fn {px, py} -> px+100*py end)
