defmodule Day11 do
  def part2 do
    v = input()

    v
    |> Enum.map(&blink(&1, 2))
    |> Enum.sum()
  end

  def blink(_, 0) do
    1
  end

  def blink(stone, times) do
    processStone(stone)
    |> Enum.map(&blink(&1, times - 1))
    |> Enum.sum()
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
    {:ok, f} = File.read("a.txt")

    f
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Day11.part2() |> IO.inspect()