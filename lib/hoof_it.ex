defmodule HoofIt do
  def get_mat(input) do
    String.split(input, "\n", [:trim]) |> Enum.map(&to_charlist(&1))
  end

  def at2(input, i, j) do
    case Enum.at(input, j, :yoverflow) do
      :yoverfow -> :yoverflow
      _ -> Enum.at(i, :xoverflow)
    end
  end

  def find_starts(input, i, j, :xoverflow, found),
    do: find_starts(input, 0, j + 1, at2(input, 0, j + 1), found)

  def find_starts(input, i, j, at, found) do
    z = at2(input, i, j)

    case z == ?0 do
      true -> MapSet.put(found, {i, j})
      false -> find_starts(input, i + 1, j, at2(input, i + 1, j), found)
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
