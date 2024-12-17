defmodule ClawContraption do
  def parse_input(input, part \\ 1) do
    splitted = String.split(input, "\n\n")
    incr = if part == 2, do: 10_000_000_000_000, else: 0

    Enum.map(splitted, fn s ->
      [btn_a, btn_b, total] = String.split(s, "\n")
      [ax, ay] = String.split(String.replace(btn_a, "Button A: ", ""), ",")
      [bx, by] = String.split(String.replace(btn_b, "Button B: ", ""), ",")
      [tx, ty] = String.split(String.replace(total, "Prize: ", ""), ",")

      {
        {String.to_integer(String.replace(ax, "X+", "") |> String.trim()),
         String.to_integer(String.replace(ay, "Y+", "") |> String.trim())},
        {String.to_integer(String.replace(bx, "X+", "") |> String.trim()),
         String.to_integer(String.replace(by, "Y+", "") |> String.trim())},
        {incr + String.to_integer(String.replace(tx, "X=", "") |> String.trim()),
         incr + String.to_integer(String.replace(ty, "Y=", "") |> String.trim())}
      }
    end)
  end

  def _solve_claw(_, b, _, _, _) when b < 0, do: :unsolvable

  def _solve_claw(a_times, b_times, target, btn_a, btn_b) do
    {{ax, ay}, {bx, by}, {tx, ty}} = {btn_a, btn_b, target}
    x = ax * a_times + bx * b_times
    y = ay * a_times + by * b_times

    cond do
      x > tx or y > ty or (x < tx and y == ty) or (x == tx and y < ty) ->
        _solve_claw(a_times, b_times - 1, target, btn_a, btn_b)

      x < tx and y < ty ->
        case a_times + b_times > 200 do
          true -> :unsolvable
          false -> _solve_claw(a_times + 1, b_times, target, btn_a, btn_b)
        end

      x == tx and y == ty ->
        {a_times, b_times}
    end
  end

  def _solve_claw2(target, btn_a, btn_b) do
    {{ax, ay}, {bx, by}, {tx, ty}} = {btn_a, btn_b, target}

    case det = ax * by - bx * ay do
      0 ->
        case rem(tx, ax) == rem(ty, ay) and rem(tx, ax) == 0 do
          true ->
            n_a = div(tx, ax)
            n_b = div(tx, bx)

            cond do
              n_a >= 3 * n_b -> {0, n_b}
              n_a < 3 * n_b -> {n_a, 0}
            end
        end

      _ ->
        # A = ([ax, bx], [ay, by])
        # A^{-1} = 1/det(A) * ([d, -b], [-c, a]) --> 1/det * ([by, -bx], [-ay, ax])
        # [ca, cb] = A^{-1} * [tx, ty] --> ca = by*tx - bx*cy
        ca = (by * tx - bx * ty) / det
        cb = (-ay * tx + ax * ty) / det

        case {Float.round(ca) - ca, Float.round(cb) - cb} do
          {a, b} when abs(a) < 1.0e-10 and abs(b) < 1.0e-10 ->
            {round(ca), round(cb)}

          _ ->
            :unsolvable
        end
    end
  end

  def solve_claw(btn_a, btn_b, target, part) do
    {target_x, target_y} = target
    {bx, by} = btn_b

    cond do
      true ->
        b_init = max(div(target_x, bx), div(target_y, by)) + 1
        a_init = 0

        case part do
          1 -> _solve_claw(a_init, b_init, target, btn_a, btn_b)
          2 -> _solve_claw2(target, btn_a, btn_b)
        end
    end
  end
end

# input = File.read!("./lib/input/claw_contraption.txt")
# import ClawContraption

# claw_machines = parse_input(input, 2)
# {btna, btnb, target} = Enum.at(claw_machines, 0)
# solve_claw(btna, btnb, target)
# results = Enum.map(claw_machines, fn {btna,btnb,target} -> solve_claw(btna,btnb,target) end)
# cost = Enum.map(results, fn r ->
#   case r do
#     :unsolvable -> 0
#     {a, b} -> a*3+b
#   end
# end) |> Enum.sum()
#
#  {a, b} = r
#
# end)
