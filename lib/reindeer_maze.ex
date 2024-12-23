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

  def dijkstra(current_node, unvisited_nodes, distances, directions) do
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
        needs_update = old_d > new_d

        case needs_update do
          false ->
            {acc_d, acc_dir}

          true ->
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
      _ -> dijkstra(min_node, new_unvisited, new_distances, new_directions)
    end
  end
end

# input = File.read!("./lib/input/reindeer_maze.txt")

# input = ~S"###############
# .......#....E#
# .#.###.#.###.#
# .....#.#...#.#
# .###.#####.#.#
# .#.#.......#.#
# .#.#####.###.#
# ...........#.#
### .#.#####.#.#
# ...#.....#.#.#
# .#.#.###.#.#.#
# .....#...#.#.#
# .###.#.#.#.#.#
# S..#.....#...#
############### "
# import ReindeerMaze
# import Utils
# grid = parse_input(input)
# wpos = walkable_positions(grid)
# edges = create_edges(wpos)
# pos = find_start(grid)
# nodes = nodes(grid)
# unvisited_nodes = MapSet.new(nodes)
# distances = Enum.reduce(nodes, Map.new(), fn node, acc ->
#   Map.put(acc, node, :infinity)
# end)
# distances = Map.put(distances, pos, 0)
# directions = %{pos => :right}
# {dir, dist} = dijkstra(pos, unvisited_nodes, distances, directions)
