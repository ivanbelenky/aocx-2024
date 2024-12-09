defmodule GuardGavillant do
  def input_to_matrix(input) do
    String.split(input, "\n")
    |> Enum.map(&String.to_charlist(&1))
  end


  def findguard_idx(arr, x, y, n, m) when x >= n do
    findguard_idx(arr, 0, y+1, n, m)
  end

  def findguard_idx(_, _, y, _, m) when y >= m do
    raise "Guard not found"
  end

  def findguard_idx(arr, x, y, n, m) do
    if Enum.at(arr, y) |> Enum.at(x) == ?^ do
      {x, y}
    else
      findguard_idx(arr, x+1, y, n, m)
    end
  end

  def at2(_, i, j) when i<0 or j<0, do: :empty

  def at2(mat, i, j) do
    val = Enum.at(mat, j, []) |> Enum.at(i, :empty)
    val
  end

  def dx(dir) do
    case dir do
      :right -> 1
      :left -> -1
      _ -> 0
    end
  end

  def dy(dir) do
    case dir do
      :up -> -1
      :down -> 1
      _ -> 0
    end
  end

  def next_dir(dir) do
    case dir do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
      _ -> :nodir
    end
  end

  def walk_and_set_guard(set_idx, _, :empty, _, _, _), do: set_idx

  def walk_and_set_guard(set_idx, dir, ?#, x, y, arr) do
    next_dir = next_dir(dir)
    {newx, newy} = {x - dx(dir) + dx(next_dir), y - dy(dir) + dy(next_dir)}
    walk_and_set_guard(set_idx, next_dir, at2(arr, newx, newy), newx, newy, arr)
  end

  def walk_and_set_guard(set_idx, dir, char, x, y, arr) when char in [?., ?^] do
    new_set = MapSet.put(set_idx, {x, y})
    {newx, newy} = {x + dx(dir), y + dy(dir)}
    walk_and_set_guard(new_set, dir, at2(arr, newx, newy), newx, newy, arr)
  end

  # I need to find all possible obstacles I can place to generate an infinite loop.
  # the nice constraint is knowing that the current puzzle configuration has no loop
  # because the last excercise asked specifically where the guard exited the room.
  # so that being said, one could argue that all the possibilities can be exhausted
  # by finding them on each interaction with a # ?
  # inspired by the example they gave.
  #
  # Given that there is only one extra obstacle one can place
  # the rest of the loop must exist already on the board
  # the path the guard takes starts always in the same place
  #
  # What does the decision space look like? One could argue that an obstacle could be
  # the process of finding an obstacle possition occurs per movement?
  # advance one square up, is "up" candidate.
  # - closest right
  #   - if not right --> no
  #   - if right
  #     - change direction
  #     - test for new square on the right
  #     - check button --> if not buttom


  def transition(x, y, arr, dir) do
    {newx, newy} = {x+dx(dir), y+dy(dir)}
    case at2(arr, newx, newy) do
      :empty -> {-1, -1, :nodir}
      ?. -> {newx, newy, dir}
      ?^ -> {newx, newy, dir}
      ?# -> {x, y, next_dir(dir)}
      ?O -> {x, y, next_dir(dir)}
      _ -> raise "WTF"
    end
  end

  def _walks_back_to?(visited, x, y, dir, arr) do
    {newx, newy, newdir} = transition(x, y, arr, dir)
    if at2(arr, newx, newy) == :empty do
      false
    else
      case MapSet.member?(visited, {newx, newy, newdir}) and newdir != :empty do
        true -> true
        false ->
          visited = MapSet.put(visited, {newx, newy, newdir})
          _walks_back_to?(visited, newx, newy, newdir, arr)
        end
    end
  end


  def check_if_loop(dir, x, y, arr) do
    visited = MapSet.new()
    visited = MapSet.put(visited, {x, y, dir})
    _walks_back_to?(visited, x, y, dir, arr)
  end



  def walk_and_check(set_idx, dir, x, y, arr, m, n) do
    if x >= m or y >= n or x<0 or y<0 do
      set_idx
    else
      {newx, newy, new_dir} = transition(x, y, arr, dir)
      new_set_idx = case at2(arr, newx, newy) do
        :empty -> set_idx
        ?# -> set_idx
        ?O -> set_idx
        ?. ->
          new_arr = List.update_at(arr, newy, fn row ->
            List.replace_at(row, newx, ?O)
          end)
          IO.puts("\n\n")
          IO.puts(Enum.join(new_arr, "\n"))
          IO.puts("\n\n")
          case check_if_loop(dir, x, y, new_arr) do
            true -> MapSet.put(set_idx, {newx, newy})
            false -> set_idx
          end
      end
      walk_and_check(new_set_idx, new_dir, newx, newy, arr, m, n)
    end
  end

  def number_of_possible_obstacles(input) do
    arr = GuardGavillant.input_to_matrix(input)
    {guard_x, guard_y} = GuardGavillant.findguard_idx(arr, 0, 0, length(Enum.at(arr, 0)), length(arr))
    set_idx = MapSet.new()
    {m, n} = {length(Enum.at(arr, 0)), length(arr)}
    set_idx = GuardGavillant.walk_and_check(set_idx, :up, guard_x, guard_y, arr, m, n)
    Enum.count(set_idx)
  end

end


#mat = GuardGavillant.input_to_matrix(File.read!("./lib/input/guard_gavillant.txt"))
#{guard_x, guard_y} = GuardGavillant.findguard_idx(mat, 0, 0, length(Enum.at(mat, 0)), length(mat))
#GuardGavillant.walk_and_set_guard(MapSet.new(), :up, ?^, guard_x, guard_y, mat)

# GuardGavillant.number_of_possible_obstacles(File.read!("./lib/input/guard_gavillant.txt"))

# ipt = ~S"....#.....
# .........#
# ..........
# ..#.......
# .......#..
# ..........
# .#..^.....
# ........#.
# #.........
# ......#..."

# GuardGavillant.number_of_possible_obstacles(ipt)
