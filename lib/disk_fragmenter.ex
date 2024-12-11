defmodule DiskFragmenter do
  def stack(input) do
    first = to_charlist(input)
      |> Enum.with_index()
      |> Enum.chunk_every(2, 2, :discard)
      |> Enum.reduce([],
        fn [{full, idx_full}, {free, _}], acc ->
          List.insert_at(acc, -1, [{:free, free - ?0}, {div(idx_full, 2), full - ?0}])
      end)
    {last, idx} = Enum.at(Enum.with_index(to_charlist(input)), -1)
    List.insert_at(first, -1, [{:free, :infinity}, {div(idx, 2), last - ?0}])
  end

  def consume_from_stack(stack, full_free_idx, n) when n-1 <= full_free_idx, do: stack
  def consume_from_stack(stack, full_free_idx, _) do
    [frinf, {id, to_consume}] = Enum.at(stack, -1)
    {:free, free_space} = Enum.at(stack, full_free_idx) |> Enum.at(0)
    if free_space == to_consume do

      at_idx = Enum.at(stack, full_free_idx)
      new_at_idx = List.replace_at(at_idx, 0, {:free, 0})
      new_at_idx = List.insert_at(new_at_idx, -1, {id, to_consume})
      stack = List.replace_at(stack, full_free_idx, new_at_idx)
      new_stack = List.delete_at(stack, -1)
      consume_from_stack(new_stack, full_free_idx+1, length(new_stack)-1)
    else
      if free_space < to_consume do
        if free_space == 0 do
          consume_from_stack(stack, full_free_idx+1, length(stack)-1)
        else
          at_idx = Enum.at(stack, full_free_idx)
          new_at_idx = List.replace_at(at_idx, 0, {:free, 0})
          new_at_idx = List.insert_at(new_at_idx, -1, {id, free_space})
          stack = List.replace_at(stack, full_free_idx, new_at_idx)
          stack = List.replace_at(stack, -1, [frinf, {id, to_consume-free_space}])
          consume_from_stack(stack, full_free_idx+1, length(stack)-1)
        end
      else
        at_idx = Enum.at(stack, full_free_idx)
        new_at_idx = List.replace_at(at_idx, 0, {:free, free_space-to_consume})
        new_at_idx = List.insert_at(new_at_idx, -1, {id, to_consume})
        stack = List.replace_at(stack, full_free_idx, new_at_idx)
        new_stack = List.delete_at(stack, -1)
        consume_from_stack(new_stack, full_free_idx, length(new_stack)-1)
      end
    end
  end

  def checksum(shuffled) do
    flat_reshuffle = List.flatten(
      Enum.map(shuffled, fn l ->
        Enum.slice(l, 1..-1//1)
      end)
    )

    Enum.reduce(flat_reshuffle, {0, 0}, fn {id, times}, acc ->
      {count, idx} = acc
      new_idx = idx + times
      new_count = Enum.sum(idx..new_idx-1) * id
      {count + new_count, new_idx}
    end)

  end


end


# input = File.read!("./lib/input/disk_fragmenter.txt")
# stack = DiskFragmenter.stack(input)
# shuffled = DiskFragmenter.consume_from_stack(stack, 0, length(stack))
