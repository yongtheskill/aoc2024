defmodule Day13 do
  def part1 do
    input()
    |> Enum.map(&nTokens/1)
    |> Enum.sum
  end
  
  def part2 do
    input()
    |> Enum.map(fn m -> %{m | x: m.x + 10000000000000, y: m.y + 10000000000000}
      end)
    |> Enum.map(&nTokens2/1)
    |> Enum.sum
  end
  
  def nTokens2(m) do
    case La.solveSim([[m.ax,m.bx,0],[m.ay,m.by,0],[3,1,-1]], [m.x,m.y,0]) do
      {:ok, res} -> 
        if res |> Enum.all?(&int?/1) do
          Enum.at(res, 2) |> round()
        else
          0
        end
      _ -> 0
    end
  end
  
  def int?(n) do
    n - Float.round(n) == 0
  end
  
  def nTokens(machine) do
    options = 1..400
    |> Stream.map(&waysToMake(0,&1))
    |> Enum.concat
    solve(options,machine)
  end
  
  def waysToMake(_, b) when b < 0 do
    []
  end
  def waysToMake(a, b) do
    [{a,b} | waysToMake(a+1, b-3)]
  end
  
  def solve([], _) do 0 end
  def solve([{a,b} | opts], m) do
    if m.x == a * m.ax + b * m.bx
      and m.y == a * m.ay + b * m.by do
      a * 3 + b
    else
      solve(opts, m)
    end
  end

  def input do
    {:ok, f} = File.read("input.txt")
    f 
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn m -> 
        [[ax,ay], [bx,by], [px, py]] = String.split(m, "\n", trim: true)
        |> Enum.map(&String.split(&1,", ", trim: true))
        
        %{ax: parseN(ax, 12),
          ay: parseN(ay, 2),
          bx: parseN(bx, 12),
          by: parseN(by, 2),
          x: parseN(px, 9),
          y: parseN(py, 2)}
      end)
  end
  
  def parseN(s, n) do
    s
    |> String.slice(n..(String.length(s)-1))
    |> String.to_integer()
  end
end

defmodule La do
  def newMat(r,c,v) do
    row = List.duplicate(v, c)
    List.duplicate(row, r)
  end
  def makeMat(r,c,f) do
    0..(r-1)
    |> Enum.map(fn y -> 
        0..(c-1)
        |> Enum.map(fn x ->
            f.(x,y)
          end)
      end)
  end
  def rows(m) do
    length(m)
  end
  def cols([row | _]) do
    length(row)
  end
  def constantMul(m,c) do
    m
    |> Enum.map(fn row ->
        Enum.map(row, &(&1 * c))
      end)
  end
  def mul(a,b) do
    r = rows(a)
    c = cols(b)
    bcols = colsAsRows(b)
    makeMat(r, c, fn x, y ->
        Enum.zip(Enum.at(a, y),Enum.at(bcols,x))
        |> Enum.map(fn {ai,bi} -> 
        ai * bi end)
        |> Enum.sum
      end)
  end
  def colsAsRows(m) do
    [firstRow | _] = m
    if firstRow == [] do
      []
    else
      {row, rest} = m
      |> Enum.reduce({[],[]}, fn row, {newCol, rest} ->
          [h | restOfRow] = row
          {[h | newCol], [restOfRow | rest]}
        end)
      [row |> Enum.reverse | colsAsRows(rest|> Enum.reverse)]
    end
  end
  def elementWise(a,b,f) do
    Enum.zip(a,b)
    |> Enum.map(fn {arow, brow} ->
        Enum.zip(arow, brow)
        |> Enum.map(fn {ax,bx} -> 
            f.(ax,bx)
          end)
      end)
  end
  def add(a,b) do
    elementWise(a,b,&(&1+&2))
  end
  def sub(a,b) do
    elementWise(a,b,&(&1-&2))
  end
  
  def firstRow([r | _]) do
    r
  end
  def firstCol(m) do
    m
    |> Enum.map(fn [e | _] ->
        [e]
      end)
  end
  def bottomRight([_ | m]) do
    m
    |> Enum.map(fn [_ | r] ->
        r
      end)
  end
  
  def luDecomp([[n]]) do
    {[[1]], [[n]]}
  end
  def luDecomp(m) do
    n = rows(m)
    {tl, tr, bl, br} = split(m)
    c = 1 / tl
    cv = constantMul(bl, c)
    toDecomp = sub(br, mul(cv, tr))
    {lp, up} = luDecomp(toDecomp)
    # L
    ltr = newMat(1,n-1,0)
    l = merge(1, ltr, cv, lp)
    # U
    ubl = newMat(n-1,1,0)
    u = merge(tl, tr, ubl, up)
    {l, u}
  end
  
  def forwardSub([[a11 | _] | a], [c1 | coeffs]) do
    fs([c1/a11], a, coeffs)
  end
  def backSub(a, c) do
    forwardSub(backToForward(a), Enum.reverse(c))
    |> Enum.reverse()
  end
  
  def backToForward(u) do
    u
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
  end
  
  def fs(res, [], []) do
    Enum.reverse(res)
  end
  def fs(previous, [an | a], [cn | coeffs]) do
    n = length(previous)
    ann = Enum.at(an, n)
    offset = [Enum.reverse(previous), an]
    |> Enum.zip_with(fn [xi, ani] -> 
        xi * ani
      end)
    |> Enum.sum
    xn = (cn - offset) / ann
    fs([xn | previous], a, coeffs)
  end
  
  # Ax = b
  def solveSim(a, b) do
    try do
      {l, u} = luDecomp(a)
      y = forwardSub(l, b)
      res = backSub(u,y)
      |> Enum.map(&Float.round(&1,3))
      {:ok, res}
    rescue
      _ -> :error
    end
  end
  
  def split(m) do 
    [tl | tr] = firstRow(m)
    [_ | bl] = firstCol(m)
    {tl, [tr], bl, bottomRight(m)}
  end
  
  def merge(tl, [tr], bl, br) do
    firstRow = [tl | tr]
    otherRows = Enum.zip(bl, br)
    |> Enum.map(fn {l, r} ->
        l ++ r
      end)
    [firstRow | otherRows]
  end
end

# La.solveSim([[94,22,0],[34,67,0],[3,1,-1]], [8400,5400,0]) |> IO.inspect(charlists: :as_lists)

# La.solveSim([[26,67,0],[66,21,0],[3,1,-1]], [12748,12176,0]) |> IO.inspect(charlists: :as_lists)

Day13.part2() |> IO.inspect

# Button A: X+94, Y+34 pressed a timus
# Button B: X+22, Y+67 pressed b times
# Prize: X=8400, Y=5400
# A: 3 tokens, B: 1 token
# total tokens = 3a + b
# 8400 = 94a + 22b
# 5400 = 34a + 67b
# c is number of tokens
# x = a•ax + b•bx --
# y = a•ay + b•by --
# c = 3a + b
# 0 = 3a + b - c --

# ax bx  0       a       x
# ay by  0   x   b   =   y
# 3  1  -1       c       0

# Ax = b
# LUx = b (decomp A)
# Ly = b (solve for y with forward substitution)
# Ux = y (solve with back sub)