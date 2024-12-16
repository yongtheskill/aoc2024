defmodule Day12 do
  def part1 do
    {grid, width, height} = input()

    g = newGraph(grid)

    unvisited =
      0..(height - 1)
      |> Enum.map(fn y ->
        0..(width - 1)
        |> Enum.map(fn x ->
          {x, y}
        end)
      end)
      |> Enum.concat()
      |> MapSet.new()

    connectedComponents(g, [], unvisited)
    |> Enum.map(fn component ->
      subgraph(g, component)
    end)
    |> Enum.map(fn subgraph ->
      area = length(subgraph)
      perimeter = area * 4 - connections(subgraph)
      area * perimeter
    end)
    |> Enum.sum()
  end

  def part2 do
    {grid, width, height} = input()

    g = newGraph(grid)

    unvisited =
      0..(height - 1)
      |> Enum.map(fn y ->
        0..(width - 1)
        |> Enum.map(fn x ->
          {x, y}
        end)
      end)
      |> Enum.concat()
      |> MapSet.new()

    connectedComponents(g, [], unvisited)
    |> Enum.map(fn component ->
      subgraph(g, component)
    end)
    |> Enum.map(fn subgraph ->
      area = length(subgraph)

      g =
        subgraph
        |> Enum.map(fn {coord, conn} -> {coord, {coord, conn}} end)
        |> Map.new()

      unvisited = g |> Map.keys() |> MapSet.new()

      sides = findSides(g, unvisited)

      area * sides
    end)
    |> Enum.sum()
  end

  @emptyMapSet MapSet.new()
  def findSides(_, unvisited) when unvisited == @emptyMapSet do
    0
  end

  def findSides(g, unvisited) do
    startCoord = Enum.at(unvisited, 0)

    case getStart(g[startCoord]) do
      nil ->
        findSides(g, MapSet.delete(unvisited, startCoord))

      dir ->
        start = {startCoord, dir}
        {current, addSides, startUnvisited} = next(g, start, unvisited)

        {sides, newUnvisited} =
          trace(
            g,
            start,
            current,
            addSides,
            startUnvisited
          )

        sides + findSides(g, newUnvisited)
    end
  end

  def trace(_, start, curr, sides, unvisited) when start == curr do
    {sides, unvisited}
  end

  def trace(g, start, curr, sides, unvisited) do
    {next, addSides, newUnvisited} = next(g, curr, unvisited)
    trace(g, start, next, sides + addSides, newUnvisited)
  end

  def next(g, {coords, dir}, unvisited) do
    currentNode = g[coords]

    cond do
      dirConnected?(currentNode, right(dir)) ->
        {{rightCoords(coords, dir), right(dir)}, 1, MapSet.delete(unvisited, coords)}

      dirConnected?(currentNode, dir) ->
        {{forwardCoords(coords, dir), dir}, 0, MapSet.delete(unvisited, coords)}

      true ->
        {{coords, left(dir)}, 1, MapSet.delete(unvisited, coords)}
    end
  end

  def getStart(node) do
    cond do
      not dirConnected?(node, :n) -> :w
      not dirConnected?(node, :s) -> :e
      not dirConnected?(node, :e) -> :n
      not dirConnected?(node, :w) -> :s
      true -> nil
    end
  end

  def right(dir) do
    case dir do
      :n -> :e
      :s -> :w
      :e -> :s
      :w -> :n
    end
  end

  def left(dir) do
    case dir do
      :n -> :w
      :s -> :e
      :e -> :n
      :w -> :s
    end
  end

  def rightCoords({x, y}, dir) do
    case dir do
      :n -> {x + 1, y}
      :s -> {x - 1, y}
      :e -> {x, y + 1}
      :w -> {x, y - 1}
    end
  end

  def forwardCoords({x, y}, dir) do
    case dir do
      :n -> {x, y - 1}
      :s -> {x, y + 1}
      :e -> {x + 1, y}
      :w -> {x - 1, y}
    end
  end

  # (node, dir)
  def dirConnected?({{x, y}, connections}, dir) do
    case dir do
      :n -> Enum.member?(connections, {x, y - 1})
      :s -> Enum.member?(connections, {x, y + 1})
      :e -> Enum.member?(connections, {x + 1, y})
      :w -> Enum.member?(connections, {x - 1, y})
    end
  end

  def connections([]) do
    0
  end

  def connections([{_, connected} | subgraph]) do
    length(connected) + connections(subgraph)
  end

  def subgraph(g, nodes) do
    getSubgraph(g, nodes, MapSet.new(nodes), [])
  end

  def getSubgraph(_, [], nodeSet, subgraph) do
    subgraph
    |> Enum.map(fn node ->
      {coords, connected} = node
      {coords, connected |> Enum.filter(&MapSet.member?(nodeSet, &1))}
    end)
  end

  def getSubgraph(g, [node | rest], nodeSet, subgraph) do
    {_, connected, coords} = getNode(g, node)

    getSubgraph(g, rest, nodeSet, [{coords, connected} | subgraph])
  end

  def connectedComponents(_, components, unvisited) when unvisited == @emptyMapSet do
    components
  end

  def connectedComponents(g, components, unvisited) do
    toVisit = Enum.at(unvisited, 0)
    {newComponent, newUnvisited} = connectedComponent(g, [], toVisit, unvisited)
    connectedComponents(g, [newComponent | components], newUnvisited)
  end

  def connectedComponent(g, component, toVisit, unvisited) do
    case MapSet.member?(unvisited, toVisit) do
      true ->
        {_, nextNodes, _} = getNode(g, toVisit)
        newComponent = [toVisit | component]
        newUnvisited = MapSet.delete(unvisited, toVisit)

        nextNodes
        |> Enum.reduce({newComponent, newUnvisited}, fn node, {nodes, unvisited} ->
          connectedComponent(g, nodes, node, unvisited)
        end)

      _ ->
        {component, unvisited}
    end
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
      case grid |> elem(y + dy) |> elem(x + dx) == el do
        true -> [{x + dx, y + dy} | next]
        _ -> next
      end
    rescue
      _ -> next
    end
  end

  def input do
    {:ok, f} = File.read("input.txt")

    grid =
      f
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "", trim: true)
        |> List.to_tuple()
      end)
      |> List.to_tuple()

    height = tuple_size(grid)
    width = tuple_size(elem(grid, 0))
    {grid, width, height}
  end
end

Day12.part2() |> IO.inspect(width: 90)
