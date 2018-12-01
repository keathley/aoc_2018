defmodule Aoc.DayOne do
  @doc """
  I did this entirely in the repl so I think I translated it into here correctly
  """
  def part_one do
    integers()
    |> Enum.sum()
  end

  def part_two do
    {answer, _, _} =
      integers()
      |> Stream.cycle
      |> Stream.scan(& &1 + &2)
      # This is amazingly inneficient since it keeps a duplicate of all previous
      # maps...but whatevs
      |> Stream.scan({nil, false, MapSet.new()}, fn(val, {_prev, result, map}) ->
        {val, MapSet.member?(map, val), MapSet.put(map, val)}
      end)
      |> Enum.find(fn {_, result, _} -> result end)

    answer
  end

  defp integers do
    File.stream!("priv/day_one_input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.reject(& &1 == "")
    |> Stream.map(&String.to_integer/1)
  end
end
