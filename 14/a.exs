defmodule Day14 do
  @width 101
  @height 103
  
  def part1 do
    quads = input()
    |> Enum.map(&runRobot(&1,100))
    |> countQuadnants()
    quads[1] * quads[2] * quads[3] * quads[4]
  end
  
  def part2 do
    # 1..100
    # |> Enum.reduce(input(),
    #   fn i, acc ->
    #     rs = acc |> Enum.map(&runRobot(&1,1))
    #     IO.puts("#{i}--------")
    #     disp(rs)
    #     rs
    #   end)
      # vertically aligned at 30
      # horizontally aligned at 81
      # 30 = x mod 103 and 81 = x mod 101
    solve(0)
    input()
    |> Enum.map(&runRobot(&1,7858))
    |> disp()
  end
  
  def solve(n) do
    if Integer.mod(n, 103) == 30 and Integer.mod(n,101) == 81 do
      n
    else
      solve(n+1)
    end
  end
  
  def disp(rs) do
    positions = rs
    |> Enum.map(fn r -> r.p end)
    |> MapSet.new()
    0..(Integer.floor_div(@height-1,2))
    |> Enum.map(fn y ->
        0..(Integer.floor_div(@width-1,2))
        |> Enum.map(fn x ->
            if MapSet.member?(positions, {x*2,y*2}) do
              IO.write("X")
            else
              IO.write(" ")
            end
          end)
          IO.write("\n")
      end)
  end
  
  def countQuadnants(robots) do
    quadWidth = Integer.floor_div(@width,2)
    quadHeight = Integer.floor_div(@height,2)
    robots
    |> Enum.map(&getQuadrant(&1,quadWidth, quadHeight))
    |> Enum.frequencies()
  end
  def getQuadrant(%{p: {x, y}},qw,qh) do
    cond do
      x == qw or y == qh -> 0
      x < qw and y < qh -> 1
      x > qw and y < qh -> 2
      x < qw and y > qh -> 3
      true -> 4
    end
  end
  
  def runRobot(r, 0) do r end
  def runRobot(r, t) do
    {x, y} = addCoords(r.p, r.v)
    runRobot(%{r | p: {Integer.mod(x, @width), Integer.mod(y, @height)}}, t-1)
  end
  
  def addCoords({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def input do
    {:ok, f} = File.read("input.txt")
    f 
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> 
        [[px,py],[vx,vy]] = String.split(s, " v=", trim: true)
        |> Enum.map(&String.split(&1,",", trim: true))
        
        %{p: {parseN(px,2), parseN(py,0)},
          v: {parseN(vx,0), parseN(vy,0)}}
      end)
  end
  
  def parseN(s, n) do
    s
    |> String.slice(n..(String.length(s)-1))
    |> String.to_integer()
  end
end

# Day14.part1() |> IO.inspect()
Day14.part2() |> IO.inspect()