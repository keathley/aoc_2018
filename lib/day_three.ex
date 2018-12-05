defmodule Aoc.DayThree do
  alias __MODULE__.Parser

  @doc """
  ## Examples

  iex> foo([
    {:foo, 1},
    {:bar, 2},
  ])
  :ok
  """
  def foo(dummy_list) do
    :ok
  end

  def part_one() do
    claims =
      File.stream!("priv/day_three_input.txt")
      |> Stream.map(&String.trim/1)
      |> Stream.map(&Parser.claim/1)
      |> Stream.map(fn {:ok, input, _, _, _, _} -> input end)
      |> Stream.map(&to_claim/1)

    claimed_coordinates =
      claims
      |> Stream.flat_map(&convert_to_plot/1)

    overlapping = overlapping_plots(claimed_coordinates)
    MapSet.size(overlapping)
  end

  def part_two() do
    claims =
      File.stream!("priv/day_three_input.txt")
      |> Stream.map(&String.trim/1)
      |> Stream.map(&Parser.claim/1)
      |> Stream.map(fn {:ok, input, _, _, _, _} -> input end)
      |> Stream.map(&to_claim/1)
      |> Stream.map(& {&1.id, convert_to_plot(&1)})

    overlapping =
      claims
      |> Stream.flat_map(fn {_, plots} -> plots end)
      |> overlapping_plots

    Enum.find_value claims, fn {id, plots} ->
      if Enum.any?(plots, & MapSet.member?(overlapping, &1)), do: false, else: id
    end
  end

  defp overlapping_plots(coordinates) do
    {_, overlapping} =
      Enum.reduce(coordinates, {MapSet.new(), MapSet.new()}, fn coord, {seen, overlapping} ->
        new_overlapping =
          if MapSet.member?(seen, coord) do
            MapSet.put(overlapping, coord)
          else
            overlapping
          end

        {MapSet.put(seen, coord), new_overlapping}
      end)

    overlapping
  end

  defp convert_to_plot(%{from_left: left, from_top: top, width: w, height: h}) do
    for x <- left..left+w-1,
        y <- top..top+h-1 do
      {x, y}
    end
  end

  defp to_claim([id, from_left, from_top, width, height]) do
    %{id: id, from_left: from_left, from_top: from_top, width: width, height: height}
  end

  defmodule Parser do
    import NimbleParsec

    id =
      ignore(string("#"))
      |> integer(min: 1)

    coordinate =
      ignore(string("@ "))
      |> integer(min: 1)
      |> ignore(string(","))
      |> integer(min: 1)

    size =
      ignore(string(": "))
      |> integer(min: 1)
      |> ignore(string("x"))
      |> integer(min: 1)

    claim =
      id
      |> ignore(string(" "))
      |> concat(coordinate)
      |> concat(size)

    defparsec :claim, claim
  end
end
