defmodule GardenGroups do
  def at2(_, i, _) when i < 0, do: :xoverflow
  def at2(_, _, j) when j < 0, do: :yoverflow

  def at2(input, i, j) do
    case y = Enum.at(input, j, :yoverflow) do
      :yoverflow -> :yoverflow
      _ -> Enum.at(y, i, :xoverflow)
    end
  end

  def at2(input, {i, j}), do: at2(input, i, j)

  # the idea is to basically once a position is given, create a BFS search algorithm

  def is_border(mat, pos, flower_type) do
    {i, j} = pos

    Enum.map([{i - 1, j}, {i + 1, j}, {i, j - 1}, {i, j + 1}], fn potential_diff ->
      at2(mat, potential_diff) != flower_type
    end)
    |> Enum.any?()
  end

  def group_discover(mat, flower_type, pos, border, group_elements) do
    border = if is_border(mat, pos, flower_type), do: MapSet.put(border, pos), else: border
    group_elements = MapSet.put(group_elements, pos)
    {i, j} = pos

    same_type_neighbors =
      Enum.filter([{i - 1, j}, {i + 1, j}, {i, j - 1}, {i, j + 1}], fn potential_diff ->
        at2(mat, potential_diff) == flower_type and
          !MapSet.member?(group_elements, potential_diff)
      end)

    {group_elements, border} =
      Enum.reduce(same_type_neighbors, {group_elements, border}, fn neigh_pos, {ge_acc, b_acc} ->
        group_discover(mat, flower_type, neigh_pos, b_acc, ge_acc)
      end)

    {group_elements, border}
  end

  def perimeter_calculator(border, group_elements, mat, flower_type, part \\ 1) do
    case part do
      1 -> perimeter_calculator_1(border, group_elements)
      2 -> perimeter_calculator_2(border, mat, flower_type)
    end
  end

  def perimeter_calculator_1(border, group_elements) do
    Enum.map(border, fn border_element ->
      {i, j} = border_element

      border =
        Enum.filter([{i - 1, j}, {i + 1, j}, {i, j - 1}, {i, j + 1}], fn potential_diff ->
          MapSet.member?(group_elements, potential_diff)
        end)
        |> Enum.count()

      4 - border
    end)
    |> Enum.sum()
  end

  def perimeter_calculator_2(border_elements, mat, flower_type) do
    borders_verbose = border_verbose(border_elements, mat, flower_type)
    map_sorted = map_and_sort_borders(borders_verbose)
    Enum.map(map_sorted, fn {dir, border} ->
      count_sides(dir, 0, 1, border)
    end) |> Enum.sum()
  end

  def area_calculator(group_elements), do: Enum.count(group_elements)

  def get_mat(input), do: String.split(input, "\n") |> Enum.map(&to_charlist(&1))

  def cost_calculator(mat, cidx, at, i, j, cost, part \\ 1)
  def cost_calculator(mat, cidxs, :xoverflow, _, j, cost, part),
    do: cost_calculator(mat, cidxs, at2(mat, 0, j + 1), 0, j + 1, cost, part)

  def cost_calculator(_mat, _cidxs, :yoverflow, _, _, cost, _), do: cost

  def cost_calculator(mat, covered_indexes, at, i, j, cost, part) do
    if MapSet.member?(covered_indexes, {i, j}) == true do
      cost_calculator(mat, covered_indexes, at2(mat, i + 1, j), i + 1, j, cost, part)
    else
      flower_type = at
      pos = {i, j}
      {ge, be} = group_discover(mat, flower_type, pos, MapSet.new(), MapSet.new())
      new_covered = MapSet.union(covered_indexes, ge)
      IO.puts("this is the perimeter at #{to_string(at2(mat, pos))}: #{inspect(perimeter_calculator(be, ge, mat, flower_type, part))}")
      IO.puts("this is the area: #{area_calculator(ge)}")

      new_cost = perimeter_calculator(be, ge, mat, flower_type, part) * area_calculator(ge)
      cost_calculator(mat, new_covered, at2(mat, i + 1, j), i + 1, j, cost + new_cost, part)
    end
  end

  def border_verbose(border_elements, mat, flower_type) do
    Enum.map(border_elements, fn border_pos ->
      {i, j} = border_pos
      IO.inspect({i,j})
      Enum.filter(
        [{:left, {i - 1, j}}, {:right, {i + 1, j}}, {:up, {i, j - 1}}, {:down, {i, j + 1}}],
        fn {_, potential_diff} ->
          IO.inspect(potential_diff)
          IO.inspect(at2(mat, potential_diff))
          at2(mat, potential_diff) != flower_type
        end
      )
    end) |> List.flatten()

  end


  def count_sides(direction, idx_0, idx_1, borders, total_count \\ 1) do
    if idx_1 == length(borders) do
      total_count
    else
      {i0, j0} = Enum.at(borders, idx_0)
      {i1, j1} = Enum.at(borders, idx_1)

      increment = case check_adjacent(direction, i0, j0, i1, j1) do
        true -> 0
        false -> 1
      end

      count_sides(direction, idx_0+1, idx_1+1, borders, total_count + increment)
    end
  end

  defp check_adjacent(:left, i0, j0, i1, j1) do
    i0 == i1 and j1 - j0 == 1
  end

  defp check_adjacent(:right, i0, j0, i1, j1) do
    i0 == i1 and j1 - j0 == 1
  end

  defp check_adjacent(:up, i0, j0, i1, j1) do
    j0 == j1 and i1 - i0 == 1
  end

  defp check_adjacent(:down, i0, j0, i1, j1) do
    j0 == j1 and i1 - i0 == 1
  end

  def sort_border(dir, a, b) when dir in [:left, :right] do
    {ia, ja} = a
    {ib, jb} = b
    cond do
      ia < ib -> true
      ia == ib -> ja <= jb
      true -> false
    end
  end

  def sort_border(dir, a, b) when dir in [:up, :down] do
    {ia, ja} = a
    {ib, jb} = b
    cond do
      ja < jb -> true
      ja == jb -> ia <= ib
      true -> false
    end
  end


  def map_and_sort_borders(borders_v) do
    dir_borders = Enum.reduce(
      borders_v,
      %{:left=>[], :right=>[], :up=>[], :down=>[]},
      fn {dir, pos}, acc ->
        dir_list = Map.get(acc, dir)
        Map.put(acc, dir, List.insert_at(dir_list, -1, pos))
    end)

    Enum.map(dir_borders, fn {dir, borders} ->
      {dir, Enum.sort(borders, fn a, b -> sort_border(dir, a, b) end)}
    end)
  end


end

# import GardenGroups
# input = ~S"OOOOO
# OXOXO
# OOOOO
# OXOXO
# OOOOO"
# input = File.read!("./lib/input/garden_groups.txt")
# mat = String.split(input, "\n") |> Enum.map(&to_charlist(&1))
# {ge, be} = group_discover(mat, ?O, {0,0}, MapSet.new(), MapSet.new())
# perimeter_calculator(be, ge)
# cost_calculator(mat, MapSet.new(), at2(mat, 0, 0), 0, 0, 0, 2)


# {ge, be} = g


# import GardenGroups
# input = ~S"EEEEE
# EXXXX
# EEEEE
# EXXXX
# EEEEE"
# mat = String.split(input, "\n") |> Enum.map(&to_charlist(&1))
# cost_calculator(mat, MapSet.new(), at2(mat, 0, 0), 0, 0, 0, 2)
# flower_type = ?E
# {ge, be} = group_discover(mat, ?E, {0,0}, MapSet.new(), MapSet.new())
#
