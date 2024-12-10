defmodule ResonantCollinearity do
  def mdist(x0,y0,x1,y1) do
    abs(x0-x1) + abs(y0-y1)
  end

  def all_antennas(mat) do
    Enum.reduce(Enum.with_index(mat), MapSet.new(), fn {row, j}, acc_all ->
      acc_local = Enum.reduce(Enum.with_index(row), MapSet.new(), fn {item, i}, acc_row ->
        case item do
          ?. -> acc_row
          _ -> MapSet.put(acc_row, {i, j, item})
        end
      end)
      MapSet.union(acc_local, acc_all)
    end)
  end

  def parse_input(input) do
    String.split(input, "\n") |> Enum.map(fn line -> to_charlist(line) end)
  end

  def at2(_, i, j) when i<0 or j<0, do: :empty
  def at2(mat, i, j) do
    row = Enum.at(mat, j, :yoverflow)
    case row do
      :yoverflow -> :yoverflow
      _ -> Enum.at(row, i, :xoverflow)
    end
  end

  def is_antinode(i, j, antenna_set, part \\ 1) do
    freq_to_pos = Enum.reduce(antenna_set, %{}, fn {x, y, freq}, acc ->
      Map.update(acc, freq, [{x, y}], fn existing -> [{x, y} | existing] end)
    end)
    antinode_check = Enum.map(freq_to_pos, fn {_, positions} ->
      n = length(positions)
      case n <= 1 do
        true -> false
        false ->
          case part do
          1 -> antinode_check_1(positions, i, j)
          2 -> antinode_check_2(positions, i, j)
        end
      end
    end)
    Enum.any?(antinode_check)
  end

  def antinode_check_1(positions, i, j) do
    drs = Enum.map(positions, fn {x,y} -> {x-i, y-j} end)
    Enum.any?(drs, fn dr ->
      {dx, dy} = dr
      if dx == 0 and dy == 0 do
        false
      else
        Enum.member?(drs, {2*dx, 2*dy}) or Enum.member?(drs, {-2*dx, -2*dy})
      end
    end)
  end

  def antinode_check_2(positions, i, j) do
    drs = Enum.map(positions, fn {x,y} -> {x-i, y-j} end)
    Enum.any?(drs, fn dr ->
      {dx, dy} = dr
      if dx != 0 and dy != 0 do
        Enum.any?(drs, fn {dx_, dy_} -> dx_ != dx and dy_ != dy and dx_/dx == dy_/dy end)
      else
        if dx == 0 do
          Enum.any?(drs, fn {dx_,_} -> dx_ == 0 and dx_ != dx end)
        else
          Enum.any?(drs, fn {_, dy_} -> dy_ == 0 and dy_ != dy end)
        end
      end
    end)
  end



  def find_antinodes(antinode_set, mat, _, j, :xoverflow, antenna_set, part) do
    find_antinodes(antinode_set, mat, 0, j+1, at2(mat, 0, j+1), antenna_set, part)
  end

  def find_antinodes(antinode_set, _, _, _, :yoverflow, _, _), do: antinode_set

  def find_antinodes(antinode_set, mat, i, j, _, antenna_set, part) do
    antinode_set = case is_antinode(i, j, antenna_set, part) do
      false -> antinode_set
      true -> MapSet.put(antinode_set, {i, j})
    end
    find_antinodes(antinode_set, mat, i+1, j, at2(mat, i+1, j), antenna_set, part)
  end
end


input = ~S"..........
..........
..........
....a.....
..........
.....a....
..........
..........
..........
.........."
