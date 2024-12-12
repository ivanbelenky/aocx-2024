defmodule HistHysteria do
  @moduledoc ~S"""
  https://adventofcode.com/2024/day/1
  """

  @spec get_locations(Path.t() | String.t()) :: {[integer()], [integer()]}
  def get_locations(file_path) do
    stream = File.stream!(file_path, encoding: :utf8)

    stream
    |> Stream.map(&String.split(String.trim(&1), " ", trim: true))
    |> Enum.reduce({[], []}, fn [l1, l2], acc ->
      {l1s, l2s} = acc
      {[String.to_integer(l1) | l1s], [String.to_integer(l2) | l2s]}
    end)
  end

  @spec solve_difference(Path.t() | String.t()) :: integer()
  def solve_difference(file_path) do
    {locations_1, locations_2} = get_locations(file_path)
    locations_1 = Enum.sort(locations_1)
    locations_2 = Enum.sort(locations_2)

    distance =
      Enum.reduce(Enum.zip(locations_1, locations_2), 0, fn {l1sorted, l2sorted}, acc ->
        acc + abs(l1sorted - l2sorted)
      end)

    distance
  end

  @spec solve_similarity_score(Path.t() | String.t()) :: integer()
  def solve_similarity_score(file_path) do
    {locations_1, locations_2} = get_locations(file_path)

    location_count =
      locations_2
      |> Enum.reduce(%{}, fn loc_id, acc ->
        {_, new_acc} =
          Map.get_and_update(acc, loc_id, fn current_count ->
            current_count = if current_count, do: current_count, else: 0
            {current_count, current_count + 1}
          end)

        new_acc
      end)

    Enum.reduce(locations_1, 0, fn lid, acc ->
      acc + lid * Map.get(location_count, lid, 0)
    end)
  end
end
