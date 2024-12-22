defmodule RestroomRedoubt do
  def parse_input(input) do
    splitted = String.split(input, "\n")

    Enum.map(splitted, fn s ->
      [p, v] = String.split(s, " ")

      [px, py] = String.split(String.replace(p, "p=", ""), ",")
      [vx, vy] = String.split(String.replace(v, "v=", ""), ",")

      {
        {String.to_integer(px), String.to_integer(py)},
        {String.to_integer(vx), String.to_integer(vy)}
      }
    end)
  end

  def transition(p, v, t, size) do
    {sx, sy} = size
    {px, py} = p
    {vx, vy} = v
    {rem(px + vx * t, sx), rem(py + vy * t, sy)}
  end

  @spec transform_to_natural_units({any(), any()}, {any(), any()}) :: {any(), any()}
  def transform_to_natural_units(pos, size) do
    {px, py} = pos
    {sx, sy} = size
    px = if px < 0, do: sx + px, else: px
    py = if py < 0, do: sy + py, else: py
    {px, py}
  end

  def cuadrant(results, xaxis, yaxis) do
    Enum.filter(results, fn pos ->
      {px, py} = pos

      in_x =
        case xaxis do
          :left -> px <= 49
          :right -> px >= 51
        end

      in_y =
        case yaxis do
          :up -> py <= 50
          :down -> py >= 52
        end

      in_x and in_y
    end)
  end

  def positions_to_grid(positions, size) do
    {sx, sy} = size

    empty_grid =
      for _y <- 0..(sy - 1) do
        for _x <- 0..(sx - 1), do: ?#
      end

    Enum.reduce(positions, empty_grid, fn {x, y}, grid ->
      List.update_at(grid, y, fn row ->
        List.replace_at(row, x, ?1)
      end)
    end)
  end

  @tree_pattern [~c"#1#", ~c"111", ~c"111"]

  def check_pattern_at_position(grid, i, j, pattern) do
    pattern_height = length(pattern)
    pattern_width = length(Enum.at(pattern, 0))

    try do
      Enum.all?(0..(pattern_height - 1), fn dy ->
        Enum.all?(0..(pattern_width - 1), fn dx ->
          grid_char = Enum.at(Enum.at(grid, j + dy), i + dx)
          pattern_char = Enum.at(Enum.at(pattern, dy), dx)
          pattern_char == grid_char
        end)
      end)
    rescue
      _ -> false
    end
  end

  def find_pattern_matches(grid) do
    Enum.with_index(grid)
    |> Enum.map(fn {row, j} ->
      Enum.with_index(row)
      |> Enum.map(fn {_, i} ->
        check_pattern_at_position(grid, i, j, @tree_pattern)
      end)
      |> Enum.filter(& &1)
      |> Enum.count()
    end)
    |> Enum.sum()
  end
end
