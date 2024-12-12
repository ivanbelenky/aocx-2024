defmodule BridgeRepair do
  def parse_input(input) do
    String.split(input, "\n")
    |> Enum.map(fn input ->
      [pot_result, operands_str] = String.split(input, ":")

      {
        String.to_integer(pot_result),
        String.split(operands_str, " ", trim: true) |> Enum.map(&String.to_integer(&1))
      }
    end)
  end

  def exec_equation(eq, idx, result \\ 1)
  def exec_equation(_, -1, result), do: result

  def exec_equation(eq, idx, result) do
    case Enum.at(eq, idx) do
      "*" -> result * exec_equation(eq, idx - 1)
      "+" -> result + exec_equation(eq, idx - 1)
      "||" -> String.to_integer(to_string(exec_equation(eq, idx - 1)) <> to_string(result))
      nil -> result
      x -> exec_equation(eq, idx - 1, x)
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
      n = length(operands) * 2 - 1

      eq =
        Enum.map(0..(n - 1), fn idx ->
          case rem(idx, 2) do
            0 -> Enum.at(operands, div(idx, 2))
            1 -> Enum.at(ops, div(idx, 2))
          end
        end)

      exec_equation(List.insert_at(eq, -1, "*"), length(eq)) == result
    end)
  end

  def eq(operands, ops) do
    n = length(operands) * 2 - 1

    Enum.map(0..(n - 1), fn idx ->
      case rem(idx, 2) do
        0 -> Enum.at(operands, div(idx, 2))
        1 -> Enum.at(ops, div(idx, 2))
      end
    end)
  end

  def all_operation_combinations_concat(operands) do
    n = length(operands) - 1
    Combinatorics.product(Enum.map(1..n, fn _ -> ["*", "+", "||"] end))
  end

  def possible2?(result, operands) do
    operators = all_operation_combinations_concat(operands)

    Enum.any?(operators, fn ops ->
      n = length(operands) * 2 - 1

      eq =
        Enum.map(0..(n - 1), fn idx ->
          case rem(idx, 2) do
            0 -> Enum.at(operands, div(idx, 2))
            1 -> Enum.at(ops, div(idx, 2))
          end
        end)

      exec_equation(List.insert_at(eq, -1, "*"), length(eq)) == result
    end)
  end
end

# resop = BridgeRepair.parse_input(File.read!("./lib/input/bridge_repair.txt"))
# resop = BridgeRepair.parse_input(ipt)
# Enum.filter(resop, fn {res, ops} ->
#  BridgeRepair.possible2?(res, ops)
# end) |> Enum.reduce(0, fn {res, _}, acc -> acc+res end)
# ipt = ~S"190: 10 19
# 3267: 81 40 27
# 83: 17 5
# 156: 15 6
# 7290: 6 8 6 15
# 161011: 16 10 13
# 192: 17 8 14
# 21037: 9 7 18 13
# 292: 11 6 16 20"
