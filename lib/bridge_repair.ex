defmodule BridgeRepair do
  def parse_input(input) do
    String.split(input, "\n") |> Enum.map(fn input ->
        [pot_result, operands_str] = String.split(input, ":")
        {
          String.to_integer(pot_result),
          String.split(operands_str, " ", trim: true) |> Enum.map(&String.to_integer(&1))}
      end)
  end

  def exec_equation(eq, idx, result \\ 1)
  def exec_equation(_, -1, result), do: result

  def exec_equation(eq, idx, result) do
    case Enum.at(eq, idx) do
      "*" -> result * exec_equation(eq, idx-1)
      "+" -> result + exec_equation(eq, idx-1)
      :nil -> result
      x -> exec_equation(eq, idx-1, x)
    end
  end

  alias Combinatronics

  def all_operation_combinations(operands) do
    n = length(operands) - 1
    Combinatorics.binary_combinations(n)
      |> Enum.map(fn tf ->
        Enum.map(tf, fn torf ->
          case torf do
            true -> "*"
            false -> "+"
          end
        end)
      end)
  end

  def possible?(result, operands) do
    operators = all_operation_combinations(operands)
    Enum.any?(operators, fn ops ->
      n = length(operands)*2 - 1
      eq = Enum.map(0..n-1, fn idx ->
        case rem(idx, 2) do
          0 -> Enum.at(operands, div(idx, 2))
          1 -> Enum.at(ops, div(idx, 2))
        end
      end)
      exec_equation(List.insert_at(eq, -1, "*"), length(eq)) == result
    end)
  end

  def eq(n, operands, ops) do
    Enum.map(0..n-1, fn idx ->
      case rem(idx, 2) do
        0 -> Enum.at(operands, div(idx, 2))
        1 -> Enum.at(ops, div(idx, 2))
      end
    end)
  end

  def possible2?(result, operands) do
    # I need to split into all the possible 2 equations. That can be done by chossing
    # all splits
    n = length(operands)
    all_splits = Enum.map(1..n-2, )

    operators = all_operation_combinations(operands)
    Enum.any?(operators, fn ops ->
      n = length(operands)*2 - 1
      eq = eq(n, operands, ops)

      exec_equation(List.insert_at(eq, -1, "*"), length(eq)) == result
    end)
  end
end


# BridgeRepair.parse_input(File.read!("./lib/input/bridge_repair.txt"))
# Enum.filter(resop, fn {res, ops} -> BridgeRepair.possible?(res, ops) end) |> Enum.reduce(0, fn {res, _}, acc -> acc+res end)
