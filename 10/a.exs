defmodule Day10 do
  def part1 do
    {grid, _width, _height} = input()

    g = newGraph(grid)

    trailHeads =
      g
      |> Tuple.to_list()
      |> Enum.map(fn row ->
        row
        |> Tuple.to_list()
        |> Enum.filter(fn el ->
          {n, _, _} = el
          n == 0
        end)
        |> Enum.map(fn el ->
          {_, _, coords} = el
          coords
        end)
      end)
      |> Enum.concat()

    trailHeads
    |> Enum.map(fn coords ->
      getPaths(g, getNode(g, coords))
      # |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def getPaths(_, {9, [], coords}) do
    [[coords]]
  end

  def getPaths(_, {_, [], _}) do
    []
  end

  def getPaths(g, {_, next, coord}) do
    next
    |> Enum.map(fn nextCoord ->
      getPaths(g, getNode(g, nextCoord))
      |> Enum.map(fn path ->
        # [coord | path]
        # this is so we get direct access to the end coordinate for part 1
        path
      end)
    end)
    |> Enum.concat()
  end

  def getNode(g, {x, y}) do
    g |> elem(y) |> elem(x)
  end

  def newGraph(grid) do
    grid
    |> Tuple.to_list()
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Tuple.to_list()
      |> Enum.with_index()
      |> Enum.map(fn {el, x} ->
        {el, findConnected(grid, {x, y}, el, [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]), {x, y}}
      end)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def findConnected(_, _, _, []) do
    []
  end

  def findConnected(grid, {x, y}, el, [{dx, dy} | rest]) do
    next = findConnected(grid, {x, y}, el, rest)

    try do
      case (grid |> elem(y + dy) |> elem(x + dx)) - el === 1 do
        true -> [{x + dx, y + dy} | next]
        _ -> next
      end
    rescue
      _ -> next
    end
  end

  def input do
    {:ok, f} = File.read("input.txt")

    inp =
      f
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "", trim: true)
        |> Enum.map(&String.to_integer(&1))
        |> List.to_tuple()
      end)
      |> List.to_tuple()

    height = tuple_size(inp)
    width = tuple_size(elem(inp, 0))
    {inp, width, height}
  end
end

Day10.part1() |> IO.inspect(width: 90)

# 2,0   2,1   3,1   3,2   3,3   2,3   2,4   3,4   4,4
