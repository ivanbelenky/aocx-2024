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

  def perimeter_calculator(border, group_elements) do
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

  def area_calculator(group_elements), do: Enum.count(group_elements)

  def get_mat(input), do: String.split(input, "\n") |> Enum.map(&to_charlist(&1))

  def cost_calculator(mat, cidxs, :xoverflow, _, j, cost),
    do: cost_calculator(mat, cidxs, at2(mat, 0, j + 1), 0, j + 1, cost)

  def cost_calculator(_mat, _cidxs, :yoverflow, _, _, cost), do: cost

  def cost_calculator(mat, covered_indexes, at, i, j, cost) do
    if MapSet.member?(covered_indexes, {i, j}) == true do
      cost_calculator(mat, covered_indexes, at2(mat, i + 1, j), i + 1, j, cost)
    else
      flower_type = at
      pos = {i, j}
      {ge, be} = group_discover(mat, flower_type, pos, MapSet.new(), MapSet.new())
      new_covered = MapSet.union(covered_indexes, ge)
      new_cost = perimeter_calculator(be, ge) * area_calculator(ge)
      cost_calculator(mat, new_covered, at2(mat, i + 1, j), i + 1, j, cost + new_cost)
    end
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
# cost_calculator(mat, MapSet.new(), at2(mat, 0, 0), 0, 0, 0)
