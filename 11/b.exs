defmodule Day11 do
  def part2 do
    v = input()

    {res, _} = v
    |> Enum.reduce({0, %{}},
      fn stone, acc ->
        {current, mem} = acc
        {new, newMem} = blink({stone, 75}, mem)
        {current + new, newMem}
      end)
    res
  end

  def blink({_, 0}, mem) do
    {1, mem}
  end

  def blink({stone, times}, mem) do
    case mem[{stone, times}] do
      nil -> {res, newMem} = 
        processStone(stone)
        |> Enum.reduce({0, mem},
          fn stone, acc ->
            {current, mem} = acc
            {new, newMem} = blink({stone, times - 1}, mem)
            {current + new, newMem}
          end)
        {res, Map.put(newMem, {stone, times}, res)}
      v -> {v, mem}
    end
  end

  def processStone(0) do
    [1]
  end

  def processStone(stone) do
    digits = countDigits(stone)

    case Integer.mod(digits, 2) do
      0 -> splitNumber(stone, digits)
      _ -> [stone * 2024]
    end
  end

  def countDigits(n) do
    (:math.log10(n)
     |> Float.floor()
     |> trunc()) + 1
  end

  def splitNumber(n, digits) do
    d = Integer.floor_div(digits, 2)
    zeros = Integer.pow(10, d)
    [Integer.floor_div(n, zeros), Integer.mod(n, zeros)]
  end

  def input do
    {:ok, f} = File.read("input.txt")

    f
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Day11.part2() |> IO.inspect()