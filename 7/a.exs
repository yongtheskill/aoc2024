defmodule Day7 do

def part1 do
  eqns = input()
  eqns
  |> Enum.filter(
  fn {res, ops} ->
    validEqn(res, ops)
  end)
  |> Enum.map(fn {res, _} -> res end)
  |> Enum.sum
end

def part2 do
  eqns = input()
  eqns
  |> Enum.filter(
  fn {res, ops} ->
    validEqn2?(res, ops)
  end)
  |> Enum.map(fn {res, _} -> res end)
  |> Enum.sum
end
def validEqn2?(res, [op | rest]) do
  valid2?(res, rest, op)
end

def valid2?(res, [], curr) do res == curr end
def valid2?(res, _, curr) when curr > res do false end
def valid2?(res, [next | rest], curr) do
  valid2?(res, rest, curr + next)
  or valid2?(res, rest, concatNum(curr, next))
  or valid2?(res, rest, curr * next)
end

def concatNum(a,b) do
  "#{a}#{b}" |> String.to_integer
end

def validEqn(res, [op | rest]) do
  valid(res, rest, op)
end

def valid(res, [], curr) do res == curr end
def valid(res, _, curr) when curr > res do false end
def valid(res, [next | rest], curr) do
  valid(res, rest, curr + next)
  or valid(res, rest, curr * next)
end


def input do
  {:ok, f} = File.read("input.txt")
  f |> String.split("\n", trim: true)
  |> Enum.map(
  fn l -> 
    [mul, ops] = l |> String.split(": ", trim: true)
    op = ops 
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    {String.to_integer(mul), op}
  end)
end
end

Day7.part2 |> IO.inspect