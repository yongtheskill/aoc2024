defmodule Day6 do
def part1 do
  {grid, width, height} = input()
  
  path = walk(guardPos(grid), 
    MapSet.new(),
    :n,
    MapSet.new(listObstacles(grid)),
    width,
    height)
    
  path |> MapSet.size
end

def part2 do
  {grid, width, height} = input()
  
  guard = guardPos(grid)
  obstacles = MapSet.new(listObstacles(grid))
  
  path = walk(guard, 
    MapSet.new(),
    :n,
    obstacles,
    width,
    height)
  
  path 
  |> Stream.map(&MapSet.put(obstacles, &1))
  |> Stream.filter(&loop?(
    guard,
    MapSet.new(),
    :n,
    &1,
    width,
    height))
  |> Enum.count
end

def part2a do
  {grid, width, height} = input()
  
  guard = guardPos(grid)
  obstacles = MapSet.new(listObstacles(grid))
  
  path = walk(guard, 
    MapSet.new(),
    :n,
    obstacles,
    width,
    height)
  
  path 
  |> Enum.map(
  fn cell ->
    Task.async(
    fn ->
      n = MapSet.put(obstacles, cell)
      loop?(
      guard,
      MapSet.new(),
      :n,
      n,
      width,
      height)
    end)
  end)
  |> Task.await_many
  |> Enum.filter(&(&1))
  |> Enum.count
end

def loop?({gx,gy}, path, dir, obs, w, h) when gx >= 0 and gy >= 0 and gx < w and gy < h do
  case MapSet.member?(path, {gx,gy,dir}) do
    true -> true
    _ -> 
    p = MapSet.put(path, {gx,gy,dir})
    next = nextCoords({gx,gy}, dir)
    case MapSet.member?(obs, next) do
      true -> loop?({gx,gy}, p, turn(dir), obs, w, h)
      _ -> loop?(next, p, dir, obs, w, h)
    end
  end
end
def loop?(_,_,_,_,_,_) do false end

def walk({gx,gy}, path, dir, obs, w, h) when gx >= 0 and gy >= 0 and gx < w and gy < h do
  p = MapSet.put(path, {gx,gy})
  next = nextCoords({gx,gy}, dir)
  case MapSet.member?(obs, next) do
    true -> walk({gx,gy}, p, turn(dir), obs, w, h)
    _ -> walk(next, p, dir, obs, w, h)
  end
end
def walk(_,path,_,_,_,_) do path end

def turn(dir) do
 case dir do
   :n -> :e
   :e -> :s
   :s -> :w
   :w -> :n
 end
end
def nextCoords({gx,gy}, dir) do
  case dir do
    :n -> {gx, gy-1}
    :s -> {gx, gy+1}
    :e -> {gx+1, gy}
    :w -> {gx-1, gy}
  end
end

def guardPos(grid) do
  grid
  |> Stream.with_index
  |> Stream.map(
  fn {row, y} -> 
    row
    |> Stream.with_index
    |> Stream.map(
    fn {elem, x} ->
      case elem do
        "^" -> {x,y}
        _ -> false
      end
    end)
    |> Enum.find(&(&1))
  end)
  |> Enum.find(&(&1))
end

def listObstacles(grid) do
  grid
  |> Enum.with_index(
    fn row, y ->
      row
      |> Enum.with_index
      |> Enum.reduce([],
        fn {elem, x}, acc ->
          case elem do
            "#" -> [{x,y} | acc]
            _ -> acc
          end
        end)
    end)
  |> Enum.concat
end

def input do
  {:ok, f} = File.read("input.txt")
  grid = f |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1,"",trim: true))
  width = length(grid)
  height = length(hd(grid))
  {grid, width, height}
end
end

Day6.part2() |> IO.inspect