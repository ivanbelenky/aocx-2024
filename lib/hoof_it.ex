defmodule HoofIt do
  def get_mat(input) do
    String.split(input, "\n") |> Enum.map(&to_charlist(&1))
  end


  def at2(_, i, _) when i<0, do: :xoverflow
  def at2(_, _, j) when j<0, do: :yoverflow
  def at2(input, i, j) do
    case y = Enum.at(input, j, :yoverflow) do
      :yoverflow -> :yoverflow
      _ -> Enum.at(y, i, :xoverflow)
    end
  end
  def at2(input, {i, j}), do: at2(input, i, j)

  def find_starts(_, _, _, :yoverflow, found), do: found

  def find_starts(input, _, j, :xoverflow, found) do
    find_starts(input, 0, j + 1, at2(input, 0, j + 1), found)
  end

  def find_starts(input, i, j, at, found) do
    new_found =
      case at == ?0 do
        false -> found
        true -> MapSet.put(found, {i, j})
      end

    find_starts(input, i + 1, j, at2(input, i + 1, j), new_found)
  end

  def find_path(_, [], _, visited), do: Enum.count(visited)
  def find_path(mat, path, did, visited) do
    current_pos = Enum.at(path, -1)
    number_at = at2(mat, current_pos)
    {i, j} = current_pos
    undone_transitions = Enum.filter([{i-1, j}, {i+1, j}, {i, j-1}, {i, j+1}], fn new_pos ->
      !MapSet.member?(did, {current_pos, new_pos}) and at2(mat, new_pos) == number_at - ?0 + ?1
    end)

    if length(undone_transitions) == 0 or number_at == ?9 do
      path = List.delete_at(path, -1)
      visited = if number_at == ?9, do: MapSet.put(visited, current_pos), else: visited
      find_path(mat, path, did, visited)
    else
      new_pos = Enum.at(undone_transitions, 0)
      did = MapSet.put(did, {current_pos, new_pos})
      path = List.insert_at(path, -1, new_pos)
      find_path(mat, path, did, visited)
    end
  end

  def find_path2(mat, path, did) do
    current_pos = Enum.at(path, -1)
    number_at = at2(mat, current_pos)
    {i, j} = current_pos
    undone_transitions = Enum.filter([{i-1, j}, {i+1, j}, {i, j-1}, {i, j+1}], fn new_pos ->
      !MapSet.member?(did, {current_pos, new_pos}) and at2(mat, new_pos) == number_at - ?0 + ?1
    end)

    if number_at == ?9 do
      1
    else
      Enum.map(undone_transitions, fn new_pos ->
        did = MapSet.put(did, {current_pos, new_pos})
        path = List.insert_at(path, -1, new_pos)
        find_path2(mat, path, did)
      end) |> Enum.sum()
    end
  end


end


# input = ~S"89010123
# 78121874
# 87430965
# 96549874
# 45678903
# 32019012
# 01329801
# 10456732"
# mat = HoofIt.get_mat(input)
# starts = HoofIt.find_starts(mat, 0, 0, HoofIt.at2(mat, 0, 0), MapSet.new())
# start = {6, 6}
# HoofIt.find_path(mat, [start], MapSet.new(), MapSet.new())
# Enum.map(starts, fn start ->
#   HoofIt.find_path(mat, [start], MapSet.new(), MapSet.new())
# end) |> Enum.sum()


# 89010123
# 78121874
# 87430965
# 96549874
# 45678903
# 32019012
# 01329801
# 10456732
