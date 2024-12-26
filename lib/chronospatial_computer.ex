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

  def _run_program(_, registers, ip, output, pl) when ip >= pl, do: {registers, output}

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

  # SOLUTION TO PART2:
  # The solution to Part 2 came from the idea of grabbing the program and
  # try to understand its semantics. The main fact is that there is a loop running
  # as many times as the highest power of 8 that is less than the value of register A.
  # If the program needs to spit itself then, one is bounded in between of

  # 8^15 - 8^16 ~ 246 billion possibilities.
  # It became apparent then that if program({:A=number}) == [out]
  # program({:A=number*8**n}) = [x0, ..., xn-1, out] where xi is "garbage"
  # then one needs to compose via this "shifting" rule, two long pieces
  # for this I cached a map between output-->number where number in [0, 8**8)
  # then it was just manual search and replace.

  # PROGRAM:  2,4,1,2,7,5,4,3,0,3,1,7,5,5,3,0
  # Starting state:                    {:A=A0,    :B=0,         :C=0}
  # (2,4) :A % 8 -> :B                 {:A=A0,    :B=A0%8,      :C=0}
  # (1,2) :B ^ 2 -> :B                 {:A=A0,    :B=(A0%8)^2,  :C=0}
  # (7,5) :A / 2**:B -> :C             {:A=A0,    :B=(A0%8)^2,  :C=A0/(2^((A0%8)^2))}
  # (4,3) :B ^ :C -> :B                {:A=A0,    :B=(A0%8)^2 ^ (A0/(2^((A0%8)^2))), :C=A0/(2^((A0%8)^2))}
  # (0,3) :A / 8 -> :A                 {:A=A0/8,  :B=(A0%8)^2 ^ (A0/(2^((A0%8)^2))), :C=A0/(2^((A0%8)^2))}
  # (1,7) :B ^ 7 -> :B                 {:A=A0/8,  :B=((A0%8)^2 ^ (A0/(2^((A0%8)^2))))^7, :C=A0/(2^((A0%8)^2))}
  # (5,5) OUTPUT :B % 8                # Outputs: ((A0%8)^2 ^ (A0/(2^((A0%8)^2))))^7 % 8
  # (3,0) jump to start if A != 0       # Loop back to start if A0/8 != 0
end
