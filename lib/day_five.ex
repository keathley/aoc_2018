defmodule Aoc.DayFive do
  def part_one(input) do
    input
    |> String.graphemes
    |> chain_react
    |> Enum.count
  end

  def chain_react(input) do
    new = react(input, [])

    if input == new do
      new
    else
      chain_react(new)
    end
  end

  def react([a], acc), do: Enum.reverse([a | acc])
  def react([a, b | rest], acc) do
    if reactable?(a, b) do
      react(rest, acc)
    else
      react([b | rest], [a | acc])
    end
  end

  defp reactable?(a, b) do
    a != b && String.downcase(a) == String.downcase(b)
  end
end
