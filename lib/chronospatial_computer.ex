defmodule ChronospatialComputer do
  def combo(operand, registers) do
    cond do
      operand <= 3 and operand >= 0 -> operand
      operand == 4 -> registers[:A]
      operand == 5 -> registers[:B]
      operand == 6 -> registers[:C]
      true -> raise "unexpected operand"
    end
  end

  def opcode_map(op, operand, registers, ip) do
    case op do
      0 ->
        operand = combo(operand, registers)
        new_registers = Map.put(registers, :A, adv(registers[:A], operand))
        {new_registers, ip + 2, :none}

      1 ->
        new_registers = Map.put(registers, :B, bitwisexor(registers[:B], operand))
        {new_registers, ip + 2, :none}

      2 ->
        :combo
        operand = combo(operand, registers)
        new_registers = Map.put(registers, :B, rem(operand, 8))
        {new_registers, ip + 2, :none}

      3 ->
        if registers[:A] == 0 do
          {registers, ip + 2, :none}
        else
          new_ip = operand
          {registers, new_ip, :none}
        end

      4 ->
        new_registers = Map.put(registers, :B, bitwisexor(registers[:B], registers[:C]))
        {new_registers, ip + 2, :none}

      5 ->
        operand = combo(operand, registers)
        output = rem(operand, 8)
        {registers, ip + 2, output}

      6 ->
        operand = combo(operand, registers)
        new_registers = Map.put(registers, :B, adv(registers[:A], operand))
        {new_registers, ip + 2, :none}

      7 ->
        operand = combo(operand, registers)
        new_registers = Map.put(registers, :C, adv(registers[:A], operand))
        {new_registers, ip + 2, :none}
    end
  end

  def adv(a, b) do
    div(a, Integer.pow(2, b))
  end

  def bitwisexor(a, b) do
    Bitwise.bxor(a, b)
  end

  def _run_program(_, _, ip, output, pl) when ip >= pl, do: output

  def _run_program(program, registers, ip, output, pl) do
    op = Enum.at(program, ip)
    operand = Enum.at(program, ip + 1)
    {registers, ip, output_item} = opcode_map(op, operand, registers, ip)
    output = if output_item == :none, do: output, else: List.insert_at(output, -1, output_item)
    _run_program(program, registers, ip, output, pl)
  end

  def run_program(program, registers) do
    pl = length(program)
    output = []
    _run_program(program, registers, 0, output, pl)
  end
end
