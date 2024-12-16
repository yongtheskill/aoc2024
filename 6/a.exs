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
  
  path = getPath(guardPos(grid), 
    MapSet.new(),
    :n,
    MapSet.new(listObstacles(grid)),
    width,
    height)
  
  path 
  |> Enum.map(fn {x,y,_} -> {x,y} end)
  |> Enum.uniq
  |> Enum.filter(&createsLoop?(&1,path))
  #|> Enum.count
end

def createsLoop?({x,y}, path) do
  checkLoop?({x+1,y}, :w, path)
  or checkLoop?({x-1,y}, :e, path)
  or checkLoop?({x,y+1}, :n, path)
  or checkLoop?({x,y-1}, :s, path)
end
def checkLoop?({x,y},dir,path) do 
  nextDir = turn(dir)
  {nx,ny} = nextCoords({x,y},nextDir)
  MapSet.member?(path, {x,y,dir})
  and MapSet.member?(path, {nx,ny,nextDir})
end

def getPath({gx,gy}, path, dir, obs, w, h) when gx >= 0 and gy >= 0 and gx < w and gy < h do
  p = MapSet.put(path, {gx,gy,dir})
  next = nextCoords({gx,gy}, dir)
  case MapSet.member?(obs, next) do
    true -> getPath({gx,gy}, p, turn(dir), obs, w, h)
    _ -> getPath(next, p, dir, obs, w, h)
  end
end
def getPath(_,path,_,_,_,_) do path end

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
  {:ok, f} = File.read("a.txt")
  grid = f |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1,"",trim: true))
  width = length(grid)
  height = length(hd(grid))
  {grid, width, height}
end
end

Day6.part2() |> IO.inspect