defmodule Aoc.DayFour do
  alias __MODULE__.Parser

  def part_one(input) do
    guard_shifts = shifts(input)

    guard_who_slept_the_most =
      guard_shifts
      |> Enum.max_by(fn {id, shifts} -> minutes_slept(shifts) end)
      |> elem(0)
      |> IO.inspect(label: "Found")

    {minute, _} =
      guard_shifts
      |> Map.get(guard_who_slept_the_most)
      |> most_minute_slept

    guard_who_slept_the_most * minute
  end

  def part_two(input) do
    {id, {minute, _}} =
      input
      |> shifts
      |> Enum.reject(fn {_, activities} -> activities == [] end)
      |> Enum.map(fn {id, activities} -> {id, most_minute_slept(activities)} end)
      |> Enum.max_by(fn {_, {_, count}} -> count end)

    id * minute
  end

  def shifts(input) do
    input
    |> Enum.sort()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> chunk
    |> Enum.group_by(fn shift -> shift.id end)
    |> Enum.map(fn {id, shifts} -> {id, Enum.flat_map(shifts, & &1.activities)} end)
    |> Enum.into(%{})
  end

  def most_minute_slept(activities) do
    activities
    |> minute_frequencies
    |> Enum.max_by(fn {_, count} -> count end)
  end

  def minute_frequencies(activities) do
    activities
    |> Enum.map(fn {d, _} -> d.minute end)
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn [start, finish] -> Enum.to_list(start..finish-1) end)
    |> Enum.reduce(%{}, fn i, acc -> Map.update(acc, i, 1, & &1 + 1) end)
  end

  def chunk(logs) do
    chunk_fn = fn {_date, status}=item, acc ->
      case status do
        {:starts, id} ->
          {:cont, acc, %{id: id, activities: []}}

        _ ->
          {:cont, %{acc | activities: acc.activities ++ [item]}}
      end
    end

    after_fn = fn
      acc -> {:cont, acc, []}
    end

    Stream.chunk_while(logs, %{}, chunk_fn, after_fn)
    |> Stream.reject(fn shift -> shift == %{} end)
  end


  def minutes_slept(shifts) do
    shifts
    |> Enum.chunk_every(2)
    |> Enum.map(fn [{t1, :sleeps}, {t2, :wakes}] -> DateTime.diff(t2, t1) end)
    |> Enum.map(fn seconds -> seconds / 60 end)
    |> IO.inspect(label: "Minutes slept")
    |> Enum.sum
  end

  def parse(string) do
    {:ok, [timestamp, status], _, _, _, _} = Parser.log(string)

    {timestamp, status}
  end

  defmodule Parser do
    import NimbleParsec

    timestamp =
      ignore(string("["))
      |> ascii_string([], 16)
      |> ignore(string("]"))
      |> map(:to_datetime)

    begin_shift =
      ignore(string("Guard #"))
      |> integer(min: 1)
      |> ignore(string(" begins shift"))
      |> unwrap_and_tag(:starts)

    falls_asleep =
      string("falls asleep")
      |> replace(:sleeps)

    wakes_up =
      string("wakes up")
      |> replace(:wakes)

    status =
      choice([
        begin_shift,
        falls_asleep,
        wakes_up,
      ])

    log =
      timestamp
      |> ignore(string(" "))
      |> concat(status)

    defparsec :log, log

    def to_datetime(ts) do
      {:ok, naive} = NaiveDateTime.from_iso8601(ts <> ":00Z")
      DateTime.from_naive!(naive, "Etc/UTC")
    end
  end
end
