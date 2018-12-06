defmodule Aoc.DayFive do
  @letters ~w|a b c d e f g h i j k l m n o p q r s t u v w x y z|

  def part_one(input) do
    input
    |> String.graphemes
    |> chain_react
    |> Enum.count
  end

  def part_two(input) do
    chars =
      input
      |> String.graphemes

    @letters
    |> Enum.map(fn c -> fn -> create_permutation(chars, c) end end)
    |> Enum.map(&Task.async/1)
    |> Enum.map(& Task.await(&1, 20_000))
    |> Enum.min
  end

  def create_permutation(chars, char) do
    chars
    |> Enum.reject(& String.downcase(&1) == char)
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

  def react([], acc), do: Enum.reverse(acc)
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
