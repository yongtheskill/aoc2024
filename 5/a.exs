defmodule Day5 do
def part1 do
  {links, orders} = input()
  
  g = links 
    |> Enum.reduce(Graph.new(), 
      fn [from, to], acc -> Graph.addEdge(acc, from, to)end)
  IO.inspect(g)
      
  # orders 
  #   |> Enum.map(&Graph.isTopoOrder?(&1, g))
end


def input do
  {:ok, f} = File.read("a.txt")
  [l, o] = String.split(f, "\n\n", trim: true)
  links = l 
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1,"|",trim: true)))
  orders = o
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1,",",trim: true)))
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
  
  def getAdj(g, n) do
    Map.fetch(g, n)
  end
  
  def isTopoOrder?(order, g) do
    isTopo?(g, order, [])
  end
  
  def isTopo?(_, [], _) do
    true
  end
  def isTopo?(_, [_], _) do
    true
  end
  def isTopo?(g, [current | others], visited) do
    [next | _] = others
    newVisited = [current] ++ visited
    if not Map.has_key?(g, next) do
      isTopo?(g, others, newVisited)
    else
      search = dfsExclude(g, current, next, visited, false)
      case search do
        {true, false} -> false
        _ -> isTopo?(g, others, newVisited)
      end
    end
  end
  
  def dfsExclude(_, from, to, _, violated) when from == to do
    {true, violated}
  end
  def dfsExclude(g, from, to, excludes, violated) do
    nextNodes = getAdj(g, from)
    violatedNow = violated or (Enum.find(excludes, fn x -> x == from end) != nil)
    case nextNodes do
      :error -> {false, violatedNow}
      {:ok, nodes} -> Enum.reduce(nodes,
        {false, violatedNow},
        fn node, acc -> 
          case acc do
            {true, _} -> acc
            {false, violated} -> dfsExclude(g, node, to, excludes, violated)
          end
        end)
    end
  end
end

Day5.part1() |> IO.inspect