defmodule PlutonianPebbles do
  @spec _transition(integer()) :: [integer()]
  def _transition(n) do
    case n == 0 do
      true ->
        [1]

      false ->
        n_str = to_string(n)
        n_digits = String.length(n_str)

        case rem(n_digits, 2) do
          0 ->
            {a, b} = String.split_at(n_str, div(n_digits, 2))
            [String.to_integer(a), String.to_integer(b)]

          1 ->
            [n * 2024]
        end
    end
  end

  def transition(list_of_n) do
    Enum.map(list_of_n, &_transition(&1)) |> List.flatten()
  end

  def _transition2(0), do: 1

  def _transition2(stone) do
    digits = Integer.digits(stone)
    len = length(digits)

    if rem(len, 2) == 0 do
      mid = div(len, 2)
      first = Enum.take(digits, mid) |> Integer.undigits()
      second = Enum.drop(digits, mid) |> Integer.undigits()
      {first, second}
    else
      2024 * stone
    end
  end

  # implementation borrowed from
  # https://elixirforum.com/t/advent-of-code-2024-day-11/68028/2
  # because I was not aware that MapSets have so much overhead for
  # lookups :S
  def count_stones(stones, depth) when is_list(stones) do
    stones
    |> Enum.map(&count_stones(&1, depth))
    |> Enum.sum()
  end

  def count_stones(stone, depth) do
    cache_key = {stone, depth}

    case :ets.lookup(:stones_cache, {stone, depth}) do
      [{_key, result}] ->
        result

      [] ->
        calculate_stones(stone, depth)
        |> tap(fn result ->
          :ets.insert(:stones_cache, {cache_key, result})
        end)
    end
  end

  def init_cache do
    if :ets.whereis(:stones_cache) != :undefined do
      :ets.delete(:stones_cache)
    end

    :ets.new(:stones_cache, [:set, :public, :named_table])
  end

  defp calculate_stones({_first, _second}, 0), do: 2
  defp calculate_stones(_stone, 0), do: 1

  defp calculate_stones(stone, depth) do
    case _transition2(stone) do
      {first, second} ->
        count_stones(first, depth - 1) + count_stones(second, depth - 1)

      stone ->
        count_stones(stone, depth - 1)
    end
  end
end

# If the stone is engraved with the number 0, it is replaced by a stone
# engraved with the number 1.
# If the stone is engraved with a number that has an even number of digits, it
# is replaced by two stones. The left half of the digits are engraved on the new
# left stone, and the right half of the digits are engraved on the new right stone.
# (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
# If none of the other rules apply, the stone is replaced by a new stone; the old stone's
# number multiplied by 2024 is engraved on the new stone.

# 0 -> 1 -> 2024 -> 20 24 -> 2 0 2 4 ->
# 1 -> 2024 -> 20 24 -> 2 0 2 4 ->
# 2 -> 4048 -> 40 48 -> 4 0 4 8
# 3 -> 6072 -> 60 72 -> 6 0 7 2
# 4 -> 8096 -> 80 96 -> 8 0 9 6
# 5 -> 10120 -> 20482880 -> 2048 2880 -> 20 48 28 80 -> 2 0 4 8 2 8 8 0
# 6 -> 12240 -> 24579456 -> 2457 9465 -> 24 57 94 65 -> 2 4 5 7 9 4 6 5
# 7 -> 14168 -> 28676032 -> 2867 6032 -> 28 67 60 32 -> 2 8 6 7 6 0 3 2
# 8 -> 16192 -> 32772608 -> 3277 2608 -> 32 77 26 08 -> 3 2 7 7 2 6 0 8
# 9 -> 18216 -> 36869184 -> 3686 9184 -> 36 86 91 84 -> 3 6 8 6 9 1 8 4

# 12 times apply the stuff to 0
# I grab 0 and I know that 0 in 4 steps will arrive at
# {
#   0: [8]
#   2: [8, 8]
#   4: [8]
# }
# {
#   0: [4, 4]
#   2: [4, 4]
#   4: [4, 4, 4]
#   6: [4]
#   8: [4, 4]
#   9: [4]
# }

#
# so I know that 1 digit
