defmodule RamRun do
  @directions [:left, :right, :up, :down]
  @all_dr [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]

  def parse_input(input) do
    String.split(input, "\n")
    |> Enum.map(&(String.split(&1, ",") |> Enum.map(fn a -> String.to_integer(a) end)))
  end

  def dijkstra_modified(
        current_state,
        visited_states,
        unvisited_states,
        distances
      ) do
    {x, y} = current_state
    new_visited = Enum.reduce(@directions, visited_states, &MapSet.put(&2, {x, y, &1}))
    dist_to_here = Map.get(distances, current_state)

    neighbors = Enum.map(@all_dr, fn {dx, dy} -> {x + dx, y + dy} end)

    unvisited_neighbors =
      Enum.filter(neighbors, fn {nx, ny} ->
        MapSet.member?(unvisited_states, {nx, ny})
      end)

    new_distances =
      Enum.reduce(unvisited_neighbors, distances, fn {nx, ny}, acc_d ->
        new_d = dist_to_here + 1
        old_d = Map.get(distances, {nx, ny})
        key = {nx, ny}

        cond do
          old_d < new_d ->
            acc_d

          old_d >= new_d ->
            Map.put(acc_d, key, new_d)
        end
      end)

    new_unvisited = MapSet.delete(unvisited_states, current_state)

    case Enum.count(new_unvisited) do
      0 ->
        new_distances

      _ ->
        min_state = Enum.min_by(unvisited_states, &Map.get(distances, &1))

        case Map.get(distances, min_state) == :infinity do
          true ->
            new_distances

          false ->
            dijkstra_modified(
              min_state,
              new_visited,
              new_unvisited,
              new_distances
            )
        end
    end
  end

  def get_unvisited_states(fallen_bytes, grid_w \\ 70, grid_h \\ 70) do
    Enum.reduce(0..grid_h, [], fn j, acc ->
      Enum.reduce(0..grid_w, acc, fn i, acci ->
        case Enum.member?(fallen_bytes, [i, j]) do
          true -> acci
          false -> List.insert_at(acci, -1, {i, j})
        end
      end)
    end)
    |> MapSet.new()
  end

  def find_path(_, 0, _, path), do: Enum.reverse(path)

  def find_path(pos, _, distances, path) do
    {x, y} = pos
    neighbors = Enum.map(@all_dr, fn {dx, dy} -> {x + dx, y + dy} end)
    next_pos = Enum.min_by(neighbors, &Map.get(distances, &1))

    case distances[next_pos] do
      :infinity ->
        :nopath

      _ ->
        next_d = distances[next_pos]
        next_path = List.insert_at(path, -1, pos)
        find_path(next_pos, next_d, distances, next_path)
    end
  end

  def get_distances(unvisited_states, start \\ {0, 0}) do
    d =
      Enum.reduce(unvisited_states, Map.new(), fn {x, y}, acc ->
        Map.put(acc, {x, y}, :infinity)
      end)

    Map.put(d, start, 0)
  end

  def find_stopping_byte(4000, _, _, _), do: :nothing

  def find_stopping_byte(enderino, distances, all_fallen_bytes, init_path) do
    [x, y] = Enum.at(all_fallen_bytes, enderino)

    case Enum.member?(init_path, {x, y}) do
      false ->
        IO.inspect("#{enderino} not blocking the road")
        find_stopping_byte(enderino + 1, distances, all_fallen_bytes, init_path)

      true ->
        IO.inspect("#{enderino} blocking the road, recalculating stuff...")
        unvisited_states = get_unvisited_states(Enum.slice(all_fallen_bytes, 0, enderino))
        distances = get_distances(unvisited_states)
        new_dists = dijkstra_modified({0, 0}, MapSet.new(), unvisited_states, distances)

        case new_dists[{70, 70}] == :infinity do
          true ->
            enderino

          false ->
            new_path = find_path({70, 70}, new_dists[{70, 70}], new_dists, [{70, 70}])
            find_stopping_byte(enderino + 1, new_dists, all_fallen_bytes, new_path)
        end
    end
  end

  def block_and_run(all_fallen_bytes, enderino) do
    unvisited_states = get_unvisited_states(Enum.slice(all_fallen_bytes, 0, enderino))
    distances = get_distances(unvisited_states)
    new_dists = dijkstra_modified({0, 0}, MapSet.new(), unvisited_states, distances)
    new_dists[{70, 70}]
  end

  def check_path_exists(all_fallen_bytes) do
    enderino = 1024
    unvisited_states = get_unvisited_states(Enum.slice(all_fallen_bytes, 0, enderino))
    distances = get_distances(unvisited_states)
    new_dists = dijkstra_modified({0, 0}, MapSet.new(), unvisited_states, distances)
    init_path = find_path({70, 70}, new_dists[{70, 70}], new_dists, [{70, 70}])
    find_stopping_byte(enderino + 1, new_dists, all_fallen_bytes, init_path)
  end
end

# import RamRun
# all_fallen_bytes = parse_input(File.read!("./lib/input/ram_run.txt"))
# check_path_exists(all_fallen_bytes)
# unvisited_states = Enum.reduce(0..70, [], fn j, acc ->
#   Enum.reduce(0..70, acc, fn i, acci ->
#     case Enum.member?(fallen_bytes, [i,j]) do
#       true -> acci
#       false -> List.insert_at(acci, -1, {i,j})
#     end
#   end)
# end) |> MapSet.new()
#
# distances = Enum.reduce(unvisited_nodes, Map.new(), fn {x,y}, acc ->
#   Map.put(acc, {x, y}, :infinity)
# end)
# distances = Map.put(distances, {0,0}, 0)
#
# dijkstra_modified({0,0}, visited_states, unvisited_states, distances)
# path = find_path(distances)
