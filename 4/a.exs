defmodule Day4 do

def part1 do
  {grid, width, height} = getGrid();
    
  Enum.map(0..width-1, fn x ->
      Enum.map(0..height-1, fn y -> getLines(grid,x,y) end)
    end) 
  |> Enum.map(fn r -> 
    Enum.map(r, fn e -> 
      Enum.filter(e, &isXmas/1) |> Enum.count
    end) |> Enum.sum
  end) |> Enum.sum
end

def part2 do
  {grid, width, height} = getGrid();

  Enum.map(0..width-1, fn x ->
      Enum.map(0..height-1, fn y -> getx(grid,x,y) end)
    end) 
  |> Enum.map(fn r -> 
    Enum.filter(r, &isx/1) |> Enum.count
  end) |> Enum.sum
end

def isx(l) do
  [a,b,c,d,e] = l
  nM = l |> Enum.filter(&(&1=="M")) |> Enum.count
  nS = l |> Enum.filter(&(&1=="S")) |> Enum.count
  c == "A" && a != e && b != d && nM == 2 && nS == 2
end

def getx(grid, x, y) when y < tuple_size(grid) - 2 and x < tuple_size(elem(grid,0)) - 2 do
  [cellAt(grid,x,y), 
  cellAt(grid,x+2,y),
  cellAt(grid,x+1,y+1),
  cellAt(grid,x,y+2),
  cellAt(grid,x+2,y+2)]
end
def getx(_,_,_) do
  ["","","","",""]
end

def isXmas(l) do
   l == ["X", "M", "A", "S"] || l == ["S", "A", "M", "X"]
end

def cellAt(grid,x,y) do
  grid |> elem(y) |> elem(x)
end

def lineAt(grid, x, y, dx, dy, length) when length > 0 and y < tuple_size(grid) and x < tuple_size(elem(grid, 0)) and x >= 0 and y >= 0 do
  [cellAt(grid, x, y) | lineAt(grid, x + dx, y + dy, dx, dy, length - 1)]
end
def lineAt(_,_,_,_,_,_) do
  []
end

def getLines(grid, x, y) do
  [lineAt(grid,x,y,0,1,4),
   lineAt(grid,x,y,1,0,4),
   lineAt(grid,x,y,1,1,4),
   lineAt(grid,x,y,-1,1,4)]
end

def getGrid do
   {:ok, f} = File.read("input.txt")
  gridList = f |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, "", trim: true)))
  grid = gridList |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple
  width = tuple_size(elem(grid,0))
  height = tuple_size(grid)
  {grid, width, height}
end

end

Day4.part1() |> IO.inspect
Day4.part2() |> IO.inspect
