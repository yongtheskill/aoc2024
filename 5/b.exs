defmodule Day5 do
def part1 do
  {links, orders} = input()

  g = links 
    |> Enum.reduce(Graph.new(), 
      fn [bef, aft], acc -> Graph.addEdge(acc, bef, aft)end)
      
  orders 
    |> Enum.filter(&validOrder?(&1,[],g))
    |> Enum.map(&middleElem/1)
    |> Enum.sum
end

def part2 do
  {links, orders} = input()

  g = links 
    |> Enum.reduce(Graph.new(), 
      fn [bef, aft], acc -> Graph.addEdge(acc, bef, aft)end)
      
  orders 
    |> Enum.filter(&!validOrder?(&1,[],g))
    |> Enum.map(&arrange(&1,[],g))
    |> Enum.map(&middleElem/1)
    |> Enum.sum
end

def arrange([], arranged, _) do arranged end
def arrange([next | rest], arranged, g) do
  arrange(rest, insert(next, arranged, g), g)
end

def insert(elem, l, g) do
 case validOrder?([elem | l], [], g) do
   true -> [elem | l] 
   _ -> [hd(l) | insert(elem, tl(l), g)]
 end
end

def middleElem(l) do
  len = length(l)
  middle = Integer.floor_div(len , 2)
  case Enum.fetch(l, middle) do
    :error -> 0
    {:ok, e} -> e
  end
end

def validOrder?([],_,_) do true end
# for all nodes, the previous nodes should not be in the allowed "after"s
def validOrder?([current | rest], visited, g) do
  v = [current | visited]
  case Graph.getNode(g, current) do
    :error -> validOrder?(rest, v, g)
    {:ok, afters} -> 
      if Enum.any?(visited, &Enum.member?(afters, &1)) do
        false
      else
        validOrder?(rest, v, g)
      end
  end
end

def input do
  {:ok, f} = File.read("input.txt")
  [l, o] = String.split(f, "\n\n", trim: true)
  links = l 
    |> String.split("\n", trim: true)
    |> Enum.map(fn r -> 
        String.split(r,"|",trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
  orders = o
    |> String.split("\n", trim: true)
    |> Enum.map(fn r-> 
        String.split(r,",",trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
  {links, orders}
end
end

defmodule Graph do
  def new do
    %{}
  end
  
  def addEdge(g, from, to) do
    res = Map.fetch(g, from)
    case res do
      :error -> Map.put(g, from, [to])
      {:ok, tos} -> Map.put(g, from, [to | tos])
    end
  end
  
  def getNode(g, n) do
    Map.fetch(g, n)
  end
end

Day5.part2() |> IO.inspect