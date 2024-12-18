defmodule Utils do
  def at2(_, i, _) when i < 0, do: :xoverflow
  def at2(_, _, j) when j < 0, do: :yoverflow

  def at2(input, i, j) do
    case y = Enum.at(input, j, :yoverflow) do
      :yoverflow -> :yoverflow
      _ -> Enum.at(y, i, :xoverflow)
    end
  end

  def at2(input, {i, j}), do: at2(input, i, j)
end
