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

  def at2(mat, i, j) when i<0, do: :empty

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
      _ -> raise "WTF?"
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

  def o(:left), do: :right
  def o(:right), do: :left
  def o(:up), do: :down
  def o(:down), do: :up


  def _walks_back_to?(x0, y0, x, y, _, _, _) when {x0, y0} == {x, y}, do: true
  def _walks_back_to?(_, _, _, _, _, :empty, _), do: false

  def _walks_back_to?(x0, y0, x, y, arr, ?#, dir) do
    newdir = next_dir(dir)
    {newx, newy} = {x-dx(dir)+dx(newdir), y-dy(dir)+dy(newdir)}
    _walks_back_to?(x0, y0, newx, newy, arr, at2(arr, newx, newy), newdir)
  end

  def _walks_back_to?(x0, y0, x, y, arr, char, dir) when char in [?., ?^] do
    {newx, newy} = {x+dx(dir), y+dy(dir)}
    _walks_back_to?(x0, y0, newx, newy, arr, at2(arr, newx, newy), dir)
  end

  def walks_back_to?(x0, y0, arr, dir) do
    newdir = next_dir(dir)
    {newx, newy} = {x0+dx(newdir), y0+dy(newdir)}
    _walks_back_to?(x0, y0, newx, newy, arr, at2(arr, newx, newy), newdir)
  end

  def check_if_loop(set_idx, dir, x, y, arr) do
    case walks_back_to?(x, y, arr, dir) do
      true -> MapSet.put(set_idx, {x, y})
      false -> set_idx
    end
  end

  def transition(x, y, arr, dir) do
    {newx, newy} = {x+dx(dir), y+dy(dir)}
    case at2(arr, newx, newy) do
      :empty -> {-1, -1, :up}
      ?. -> {newx, newy, dir}
      ?^ -> {newx, newy, dir}
      ?# -> {x+dx(next_dir(dir)), y+dy(next_dir(dir)), next_dir(dir)}
    end
  end

  def walk_and_check(set_idx, dir, x, y, arr, m, n) do
    if x >= m or y >= n or x<0 or y<0 do
      set_idx
    else
      new_set_idx = check_if_loop(set_idx, dir, x, y, arr)
      {newx, newy, new_dir} = transition(x, y, arr, dir)
      walk_and_check(new_set_idx, new_dir, newx, newy, arr, m, n)
    end

  end

  def number_of_possible_obstacles(input) do
    arr = input_to_matrix(input)
    {guard_x, guard_y} = GuardGavillant.findguard_idx(arr, 0, 0, length(Enum.at(arr, 0)), length(arr))
    set_idx = MapSet.new()
    {m, n} = {length(Enum.at(arr, 0)), length(arr)}
    set_idx = walk_and_check(set_idx, :up, guard_x, guard_y, arr, m, n)
    Enum.count(set_idx)
  end

end


#mat = GuardGavillant.input_to_matrix(File.read!("./lib/input/guard_gavillant.txt"))
#{guard_x, guard_y} = GuardGavillant.findguard_idx(mat, 0, 0, length(Enum.at(mat, 0)), length(mat))
#GuardGavillant.walk_and_set_guard(MapSet.new(), :up, ?^, guard_x, guard_y, mat)
