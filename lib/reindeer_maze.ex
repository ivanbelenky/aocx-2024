defmodule ReindeerMaze do
  import Utils, only: [at2: 2, at2: 3]

  def parse_input(input) do
    String.split(input, "\n") |> Enum.map(&String.to_charlist(&1))
  end

  import WarehouseWoes, only: [get_positions_of_char: 2]

  def find_start(grid), do: Enum.at(get_positions_of_char(grid, ?S), 0)
  def find_end(grid), do: Enum.at(get_positions_of_char(grid, ?E), 0)

  def walkable_positions(grid), do: get_positions_of_char(grid, ?.)
  @all_dr [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  def create_edges(walkable_positions) do
    Enum.reduce(walkable_positions, MapSet.new(), fn {wx, wy}, acc ->
      neighbors = Enum.map(@all_dr, fn {dx, dy} -> {wx + dx, wy + dy} end)

      Enum.reduce(neighbors, acc, fn {neighx, neighy}, acc2 ->
        case MapSet.member?(walkable_positions, {neighx, neighy}) do
          false ->
            acc2

          true ->
            new_acc = MapSet.put(acc2, {{neighx, neighy}, {wx, wy}})
            MapSet.put(new_acc, {{wx, wy}, {neighx, neighy}})
        end
      end)
    end)
  end

  def nodes(grid) do
    se = MapSet.new([find_start(grid), find_end(grid)])
    MapSet.union(get_positions_of_char(grid, ?.), se)
  end

  def needs_rotation?(a, b, dir) do
    {ax, ay} = a
    {bx, by} = b
    {dx, dy} = {ax - bx, ay - by}

    cond do
      dx != 0 -> dir in [:up, :down]
      dy != 0 -> dir in [:left, :right]
      dx != 0 and dy != 0 -> raise "Wtferino"
    end
  end

  def new_direction(a, b) do
    {ax, ay} = a
    {bx, by} = b
    {dx, dy} = {bx - ax, by - ay}

    case {dx, dy} do
      {-1, 0} -> :left
      {1, 0} -> :right
      {0, -1} -> :up
      {0, 1} -> :down
    end
  end

  def dijkstra(
        current_node,
        visited_nodes,
        unvisited_nodes,
        distances,
        directions
      ) do
    new_visited = MapSet.put(visited_nodes, current_node)

    {x, y} = current_node
    current_direction = Map.get(directions, current_node)
    dist_to_here = Map.get(distances, current_node)

    neighbors = Enum.map(@all_dr, fn {dx, dy} -> {x + dx, y + dy} end)

    unvisited_neighbors =
      Enum.filter(neighbors, fn n ->
        MapSet.member?(unvisited_nodes, n)
      end)

    {new_distances, new_directions} =
      Enum.reduce(unvisited_neighbors, {distances, directions}, fn {nx, ny}, {acc_d, acc_dir} ->
        needs_rot = needs_rotation?({nx, ny}, current_node, current_direction)
        new_d = if(needs_rot, do: 1001, else: 1) + dist_to_here
        old_d = Map.get(acc_d, {nx, ny}, :infinity)

        cond do
          new_d > old_d ->
            {acc_d, acc_dir}

          new_d < old_d ->
            acc_d = Map.put(acc_d, {nx, ny}, new_d)

            new_direction =
              if needs_rot, do: new_direction(current_node, {nx, ny}), else: current_direction

            acc_dir = Map.put(acc_dir, {nx, ny}, new_direction)
            {acc_d, acc_dir}
        end
      end)

    new_unvisited = MapSet.delete(unvisited_nodes, current_node)
    min_node = Enum.min_by(unvisited_nodes, &Map.get(distances, &1))

    case Enum.count(new_unvisited) do
      0 -> {new_directions, new_distances}
      _ -> dijkstra(min_node, new_visited, new_unvisited, new_distances, new_directions)
    end
  end

  @directions [:left, :right, :up, :down]

  def opposite?(a, b) do
    case {a, b} do
      {:up, :down} -> true
      {:down, :up} -> true
      {:left, :right} -> true
      {:right, :left} -> true
      _ -> false
    end
  end

  def dijkstra_modified(
        current_state,
        visited_states,
        unvisited_states,
        distances,
        paths_to_state
      ) do
    {x, y, dir} = current_state
    new_visited = Enum.reduce(@directions, visited_states, &MapSet.put(&2, {x, y, &1}))
    dist_to_here = Map.get(distances, current_state)

    neighbors = Enum.map(@all_dr, fn {dx, dy} -> {x + dx, y + dy} end)

    unvisited_neighbors =
      Enum.filter(neighbors, fn {nx, ny} ->
        Enum.map(@directions, &MapSet.member?(unvisited_states, {nx, ny, &1})) |> Enum.any?()
      end)

    {new_distances, new_paths_to_state} =
      Enum.reduce(unvisited_neighbors, {distances, paths_to_state}, fn {nx, ny},
                                                                       {acc_d, acc_paths} ->
        new_dir = new_direction({x, y}, {nx, ny})
        needs_rot = dir != new_dir
        d_modifier = if needs_rot, do: 1000, else: 0
        the_distance = dist_to_here + 1 + d_modifier
        direction = new_dir

        old_d = Map.get(distances, {nx, ny, new_dir})
        new_d = the_distance
        key = {nx, ny, direction}

        cond do
          old_d < new_d ->
            {acc_d, acc_paths}

          old_d == new_d ->
            next_paths = Map.get(acc_paths, key)
            current_paths = Map.get(acc_paths, current_state)
            new_path_items = MapSet.union(next_paths, MapSet.put(current_paths, current_state))
            new_acc_paths_to_state = Map.put(acc_paths, key, new_path_items)

            {acc_d, new_acc_paths_to_state}

          old_d > new_d ->
            current_paths = Map.get(acc_paths, current_state)
            new_path_items = MapSet.put(current_paths, current_state)
            new_acc_distances = Map.put(acc_d, key, new_d)
            new_acc_paths_to_state = Map.put(acc_paths, key, new_path_items)
            {new_acc_distances, new_acc_paths_to_state}
        end
      end)

    new_unvisited = MapSet.delete(unvisited_states, current_state)

    case Enum.count(new_unvisited) do
      0 ->
        {new_distances, new_paths_to_state}

      _ ->
        min_state = Enum.min_by(unvisited_states, &Map.get(distances, &1))

        case Map.get(distances, min_state) == :infinity do
          true ->
            {new_distances, new_paths_to_state}

          false ->
            dijkstra_modified(
              min_state,
              new_visited,
              new_unvisited,
              new_distances,
              new_paths_to_state
            )
        end
    end
  end
end

# input = File.read!("./lib/input/reindeer_maze.txt")
# import ReindeerMaze
# import Utils
# grid = parse_input(input)
# wpos = walkable_positions(grid)
# edges = create_edges(wpos)
# pos = find_start(grid)
# nodes = nodes(grid)
# unvisited_nodes = Enum.map(nodes, fn {nx, ny} -> Enum.map([:left, :right, :up, :down], &({nx, ny, &1})) end) |> List.flatten() |> MapSet.new()
# distances = Enum.reduce(nodes, Map.new(), fn node, acc ->
#   Enum.reduce([:left, :right, :up, :down], acc, fn dir, acc_dir ->
#     {nx, ny} = node
#     Map.put(acc_dir, {nx, ny, dir}, :infinity)
#   end)
# end)
# {posx, posy} = pos
# distances = Map.put(distances, {posx, posy, :right}, 0)
# distances = Map.put(distances, {posx, posy, :up}, 1000)
# distances = Map.put(distances, {posx, posy, :down}, 1000)
# distances = Map.put(distances, {posx, posy, :left}, 1000)
# {start_x, start_y} = find_start(grid)
# paths = Enum.reduce(nodes, Map.new(), fn node, acc ->
#   Enum.reduce([:left, :right, :up, :down], acc, fn dir, acc_paths ->
#     {nx, ny} = node
#     Map.put(acc_paths, {nx, ny, dir}, MapSet.new())
#   end)
# end)
# {distances, paths} = dijkstra_modified({start_x, start_y, :right}, MapSet.new(), unvisited_nodes, distances, paths)
# {endx,endy} = find_end(grid)

# Solution I am lazy
# e = {endx, endy, :up}
# paths[e] |> Enum.map(fn {x,y,_z} -> {x,y} end) |> MapSet.new() |> Enum.count()
