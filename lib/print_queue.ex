defmodule PrintQueue do

  def get_rules_and_updates(input) do
    [rules_str, updates_str] = String.split(input, "\n\n", parts: 2)
    updates = String.split(updates_str, "\n")
    rules = rules_str
      |> String.split("\n")
      |> Enum.reduce(%{}, fn rule, acc ->
        [k, v] = String.split(rule, "|")
        Map.put(acc, v, Map.get(acc, v, []) ++ [k])
      end)
    {rules, updates}
  end

  def valid_update(update, rules) do
    pages = String.split(update, ",") |> Enum.with_index()
    !Enum.any?(pages, fn {p, idx} ->
      next_pages = Enum.slice(pages, idx+1..-1//1)
      Enum.any?(next_pages, fn {np, _} -> Enum.member?(Map.get(rules, p, []), np) end)
    end)
  end

  def sum_of_valid_updates(input) do
    {rules, updates} = get_rules_and_updates(input)
    Enum.filter(updates, &(valid_update(&1, rules)))
      |> Enum.map(fn up ->
        pages = String.split(up, ",")
        String.to_integer(Enum.at(pages, div(length(pages)-1,2)))
      end)
      |> Enum.sum()
  end

  def order_disorder_updates(input) do
    {rules, updates} = get_rules_and_updates(input)
    Enum.filter(updates, &(!valid_update(&1, rules))) |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn up ->
      Enum.sort(up, fn p1, p2 ->
        if Map.get(rules, p1, []) == [] do
          true
        else
          !Enum.member?(Map.get(rules, p1, []), p2)
        end
      end)
    end)
  end

  def sum_of_ordered_updates(input) do
    order_disorder_updates(input)
      |> Enum.map(fn up ->
        String.to_integer(Enum.at(up, div(length(up)-1,2)))
      end)
      |> Enum.sum()
  end

end
