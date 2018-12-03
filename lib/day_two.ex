defmodule Aoc.DayTwo do
  @letters ~w|a b c d e f g h i j k l m n o p q r s t u v w x y z|
  alias Aoc.DayTwo.Trie

  def part_one do
    {twos, threes} =
      words()
      |> Stream.map(&into_counts/1)
      |> Enum.reduce(fn {twos, threes}, {old_twos, old_threes} -> {twos+old_twos, threes+old_threes} end)

    twos * threes
  end

  def part_two() do
    word_list = words()

    # This way is slow and boring since its O(n^2) but its
    # easy to validate its correctness while I worked out an efficient alg.
    # {original, _slow} = find_it_slow(word_list)

    # This way is awesome!
    # It generates a trie for fast lookups. Then instead of doing O(n^2)
    # comparisons we generate all of the possible permutations of words on demand
    # and see if they're in the trie. This multiplies the search space but its
    # still linear time so it ends up being much faster.
    #
    # On my machine Benchee says the trie is 2.6x faster.
    find_it_fast(word_list)
  end

  def bench() do
    word_list = words()

    Benchee.run(%{
      "brute force" => fn -> find_it_slow(word_list) end,
      "trie" => fn -> find_it_fast(word_list) end,
    })
  end

  def find_it_slow(word_list) do
    Enum.find_value word_list, fn word ->
      Enum.find_value word_list, fn test_word ->
        case String.myers_difference(word, test_word) do
          [eq: first, del: d, ins: i, eq: last] ->
            if String.length(d) == 1 && String.length(i) == 1, do: {word, first <> last}

          [eq: first, del: d, ins: i] ->
            if String.length(d) == 1 && String.length(i) == 1, do: {word, first}

          [del: d, ins: i, eq: last] ->
            if String.length(d) == 1 && String.length(i) == 1, do: {word, last}

          _ ->
            false
        end
      end
    end
  end

  def find_it_fast(word_list) do
    word_list =
      word_list
      |> Stream.map(&String.graphemes/1)

    trie =
      word_list
      |> Enum.reduce(Trie.new(), fn word, trie -> Trie.insert(trie, word) end)

    pid = self()

    # For each word in the list spawn a process and do a search. We'll block
    # until a process responds.
    Enum.each word_list, fn word ->
      spawn(fn ->
        Enum.each permutations(word), fn p ->
          if Trie.member?(trie, p) do
            send(pid, {:found, {word, p}})
          end
        end
      end)
    end

    {id1, id2} =
      receive do
        {:found, answer} -> answer
      end

    # Since we know that these ids are only different in one char we can zip
    # the two words together and filter out the char that doesn't match.
    # Once thats done we can join the chars back together to get the answer.
    Enum.zip(id1, id2)
    |> Enum.filter(fn {a, b} -> a == b end)
    |> Enum.map(fn {_, a} -> a end)
    |> Enum.join("")
  end

  def permutations(word) do
    # Creates a set of splits to make it easy to generate permutated strings
    # We want to create a left and right side with a single character in the
    # middle
    splits = for i <- 0..Enum.count(word)-1 do
      {Enum.take(word, i), Enum.at(word, i), Enum.drop(word, i+1)}
    end

    # Using our splits and every letter except the letter we're replacing,
    # create a new word.
    for {l, c, r} <- splits,
        replacement <- List.delete(@letters, c) do
      l ++ [replacement] ++ r
    end
  end

  defp words do
    File.stream!("priv/day_two_input.txt")
    |> Stream.map(&String.trim/1)
  end

  defp into_counts(word) do
    counts =
      word
      |> String.graphemes
      |> Enum.group_by(& &1) # I really wish a lot of enum functions took an identity function by default
      |> Enum.map(fn {_, grouped} -> Enum.count(grouped) end)
      |> Enum.filter(& &1 == 2 || &1 == 3)
      |> Enum.uniq

    {zero_or_one(counts, 2), zero_or_one(counts, 3)}
  end

  defp zero_or_one(counts, num) do
    if Enum.any?(counts, & &1 == num), do: 1, else: 0
  end
end

defmodule Aoc.DayTwo.Trie do
  def new, do: %{end: false}

  def insert(trie, word) do
    do_insert(trie, word)
  end

  def member?(trie, word) do
    lookup(trie, word)
  end

  defp do_insert(trie, []), do: %{trie | end: true}
  defp do_insert(trie, [letter | rest]) do
    case trie[letter] do
      nil ->
        Map.put(trie, letter, do_insert(new(), rest))

      node ->
        Map.put(trie, letter, do_insert(node, rest))
    end
  end

  defp lookup(%{end: end?}, []), do: end?
  defp lookup(trie, [char | rest]) do
    case Map.get(trie, char) do
      nil ->
        false

      node ->
        lookup(node, rest)
    end
  end
end

