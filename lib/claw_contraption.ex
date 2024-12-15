defmodule ClawContraption do
  def parse_input(input, part \\ 1) do
    splitted = String.split(input, "\n\n")
    incr = if part == 2, do: 10000000000000, else: 0
    Enum.map(splitted, fn s ->
      [btn_a, btn_b, total] = String.split(s, "\n")
      [ax, ay] = String.split(String.replace(btn_a, "Button A: ", ""), ",")
      [bx, by] = String.split(String.replace(btn_b, "Button B: ", ""), ",")
      [tx, ty] = String.split(String.replace(total, "Prize: ", ""), ",")
      {
        {String.to_integer(String.replace(ax, "X+", "") |> String.trim()), String.to_integer(String.replace(ay, "Y+", "") |> String.trim())},
        {String.to_integer(String.replace(bx, "X+", "") |> String.trim()), String.to_integer(String.replace(by, "Y+", "") |> String.trim())},
        {incr+String.to_integer(String.replace(tx, "X=", "") |> String.trim()), incr+String.to_integer(String.replace(ty, "Y=", "") |> String.trim())},
      }
    end)
  end

  def _solve_claw(_, b, _, _, _) when b<0, do: :unsolvable

  def _solve_claw(a_times, b_times, target, btn_a, btn_b) do
    {{ax, ay}, {bx, by}, {tx, ty}} = {btn_a, btn_b, target}
    x = ax*a_times + bx*b_times
    y = ay*a_times + by*b_times
    cond do
      (x>tx or y>ty) or (x<tx and y==ty) or (x==tx and y<ty) -> _solve_claw(a_times, b_times-1, target, btn_a, btn_b)
      x<tx and y<ty ->
        case a_times + b_times > 200 do
          true -> :unsolvable
          false -> _solve_claw(a_times+1, b_times, target, btn_a, btn_b)
        end
      x==tx and y==ty ->
        {a_times, b_times}
    end
  end


  def solve_claw(btn_a, btn_b, target) do
    {target_x, target_y} = target
    {bx, by} = btn_b
    cond do
      true ->
        b_init = max(div(target_x, bx), div(target_y, by)) + 1
        a_init = 0
        _solve_claw(a_init, b_init, target, btn_a, btn_b)
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
