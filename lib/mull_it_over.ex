defmodule MullItOver do
  def mulsum(file_content) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, file_content)
      |> Enum.map(fn [m] ->
        [[a], [b]] =  Regex.scan(~r/\d{1,3}/, m)
        String.to_integer(a) * String.to_integer(b)
      end)
      |> Enum.sum()
  end

  def find_mul(file_path) do
    file_content = String.trim(File.read!(file_path))
    mulsum(file_content)
  end

  def find_mul_with_instruction(file_path) do
    file_content = String.trim(File.read!(file_path))
    [first | rest ] = Regex.split(~r/don't\(\)/, file_content, parts: 1000) # manual verification hack
    rest_val = rest
      |> Enum.map(fn parts ->
        do_parts = Regex.split(~r/do\(\)/, parts, parts: 1000)
        if length(do_parts) == 1 do
          0
        else
          {_, do_parts} = List.pop_at(do_parts, 0)
          Enum.reduce(do_parts, 0, &(mulsum(&1)+&2))
        end
      end)
      |> Enum.sum()
    rest_val+mulsum(first)
  end
end
