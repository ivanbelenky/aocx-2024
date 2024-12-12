defmodule CeresSearch do
  @pad 3

  def replicate(n, x), do: for(_ <- 1..n, do: x)

  def input_to_list_of_charlist(input, pad \\ 3) do
    charlists =
      String.split(input, "\n", [:trim])
      |> Enum.map(fn line ->
        padding = replicate(pad, ~c" ")
        right_pad = [String.to_charlist(line) | padding]
        [padding | right_pad]
      end)
      |> Enum.map(fn line -> List.flatten(line) end)

    n = length(Enum.at(charlists, 0)) + pad * 2
    padding = replicate(pad, List.flatten(replicate(n, ~c" ")))
    padding ++ charlists ++ padding
  end

  @up [{-1, 0}, {-1, 0}, {-1, 0}]
  @down [{1, 0}, {1, 0}, {1, 0}]
  @left [{0, -1}, {0, -1}, {0, -1}]
  @right [{0, 1}, {0, 1}, {0, 1}]
  @up_right [{-1, 1}, {-1, 1}, {-1, 1}]
  @up_left [{-1, -1}, {-1, -1}, {-1, -1}]
  @down_right [{1, 1}, {1, 1}, {1, 1}]
  @down_left [{1, -1}, {1, -1}, {1, -1}]

  def xmas_count(_, i, j, _, _) when i < 3 or j < 3, do: 0
  def xmas_count(_, i, j, n, m) when i > m - 4 or j > n - 4, do: 0

  def xmas_count(loc, i, j, _, _) do
    Enum.filter(
      [@up, @down, @left, @right, @up_right, @up_left, @down_right, @down_left],
      fn path ->
        xmas =
          Enum.reduce(path, {[?X], i, j}, fn {di, dj}, {acc, ci, cj} ->
            next_char = Enum.at(Enum.at(loc, cj + dj), ci + di)
            {[next_char | acc], ci + di, cj + dj}
          end)
          |> elem(0)
          |> Enum.reverse()

        xmas == [?X, ?M, ?A, ?S]
      end
    )
    |> Enum.count()
  end

  def find_xmas(input) do
    list_of_charlists = input_to_list_of_charlist(input)
    {n, m} = {length(list_of_charlists), length(Enum.at(list_of_charlists, 0))}

    list_of_charlists
    |> Enum.with_index()
    |> Enum.map(fn {line, idx_line} ->
      Enum.with_index(line)
      |> Enum.map(fn {char, idx_inline} ->
        case char do
          ?X -> xmas_count(list_of_charlists, idx_inline, idx_line, n, m)
          _ -> 0
        end
      end)
      |> Enum.sum()
    end)
  end

  @mas_x_mask_0 [~c"M#S", ~c"#A#", ~c"M#S"]
  @mas_x_mask_1 [~c"S#S", ~c"#A#", ~c"M#M"]
  @mas_x_mask_2 [~c"S#M", ~c"#A#", ~c"S#M"]
  @mas_x_mask_3 [~c"M#M", ~c"#A#", ~c"S#S"]

  def check_mask_rec(loc, i, j, mask_i, mask_j, mask, mm, mn) when mask_i > mn - 1 do
    check_mask_rec(loc, i, j, 0, mask_j + 1, mask, mm, mn)
  end

  def check_mask_rec(_, _, _, _, mask_j, _, mm, _) when mask_j > mm - 1, do: true

  def check_mask_rec(loc, i, j, mask_i, mask_j, mask, mm, mn) do
    val = Enum.at(loc, j + mask_j) |> Enum.at(i + mask_i)
    mask_val = Enum.at(mask, mask_j) |> Enum.at(mask_i)

    if val != mask_val and mask_val != ?# do
      false
    else
      check_mask_rec(loc, i, j, mask_i + 1, mask_j, mask, mm, mn)
    end
  end

  def check_mask(loc, i, j, mask) do
    check_mask_rec(loc, i, j, 0, 0, mask, length(mask), length(Enum.at(mask, 0)))
  end

  def find_mas_x(input, pad \\ @pad) do
    list_of_charlists = input_to_list_of_charlist(input, pad)

    Enum.with_index(list_of_charlists)
    |> Enum.map(fn {line, j} ->
      Enum.with_index(line)
      |> Enum.map(fn {_, i} ->
        check_mask(list_of_charlists, i, j, @mas_x_mask_0) or
          check_mask(list_of_charlists, i, j, @mas_x_mask_1) or
          check_mask(list_of_charlists, i, j, @mas_x_mask_2) or
          check_mask(list_of_charlists, i, j, @mas_x_mask_3)
      end)
      |> Enum.filter(& &1)
      |> Enum.count()
    end)
    |> List.flatten()
    |> Enum.sum()
  end
end
