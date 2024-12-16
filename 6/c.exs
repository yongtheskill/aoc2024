# defmodule PathStore do
#   def new do %{} end
  
#   def member?(s, {x,y,dir}) do
#     case s[x][y][dir] do
#       nil -> false
#       _ -> true
#     end
#   end
  
#   def put_if(s, {x,y,dir}) do
#     case s[x] do
#       nil -> Map.put(s, x, %{y: %{dir: true}})
#       ys -> 
#       case ys[y] do
#         nil -> put_in(s[x][y], %{dir: true})
#         ds -> 
#         case Map.has_key?(ds, dir) do
#           false -> put_in(s[x][y][dir], true)
#           _ -> true
#         end
#       end
#     end
#   end
# end

defmodule PathStore do
  def new(x,y) do 
    Tuple.duplicate(
      Tuple.duplicate({false, false, false, false}, x),
      y)
  end
  
  def member?(s, {x,y,dir}) do
    case s[x][y][dir] do
      nil -> false
      _ -> true
    end
  end
  
  def put_if(s, {x,y,dir}) do
    try do
      row = elem(s, y)
      cell = elem(row, x)
      case elem(row, x)
    rescue
      _ -> false
    end
  end
  
  def cellHas(cell, dir) do
    case dir do
      :n -> elem(cell, 0)
      :s -> elem(cell, 1)
      :e -> elem(cell, 2)
      :w -> elem(cell, 3)
    end
  end
end

defmodule ObsStore do
  def new(g) do
    g
    |> Enum.map(
    fn r -> 
      Enum.map(r, &(&1=="#"))
      |> List.to_tuple
    end)
    |> List.to_tuple
  end
  
  def put(s, {x,y}) do
    put_elem(s, y,
      put_elem(elem(s, y), x, true))
  end
  
  def member?(s, {x,y}) do
    try do
      s |> elem(y) |> elem(x)
    rescue
      _ -> false
    end
  end
end

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
  obstacles = ObsStore.new(grid)
  
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
      loop?(
      guard,
      PathStore.new(),
      :n,
      ObsStore.put(obstacles, cell),
      width,
      height)
    end)
  end)
  |> Task.await_many
  |> Enum.filter(&(&1))
  |> Enum.count
end

def loop?({gx,gy}, path, dir, obs, w, h) when gx >= 0 and gy >= 0 and gx < w and gy < h do
  case PathStore.put_if(path, {gx,gy,dir}) do
    true -> true
    p -> 
    next = nextCoords({gx,gy}, dir)
    case ObsStore.member?(obs, next) do
      true -> loop?({gx,gy}, p, turn(dir), obs, w, h)
      _ -> loop?(next, p, dir, obs, w, h)
    end
  end
end
def loop?(_,_,_,_,_,_) do false end

def walk({gx,gy}, path, dir, obs, w, h) when gx >= 0 and gy >= 0 and gx < w and gy < h do
  p = MapSet.put(path, {gx,gy})
  next = nextCoords({gx,gy}, dir)
  case ObsStore.member?(obs, next) do
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

Day6.part2 |> IO.inspect