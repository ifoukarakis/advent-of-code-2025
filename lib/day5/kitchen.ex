defmodule Kitchen.Reader do
  def read_db(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.split_while(&(&1 != ""))
    |> then(fn {first, second} ->
      {first, Enum.drop(second, 1)}
    end)
  end

  def as_range(str) do
    [from, to | _] = str |> String.split("-") |> Enum.map(&String.to_integer/1)
    Range.new(from, to)
  end

  def read(path) do
    {a, b} = read_db(path)
    {
      a |> Enum.map(&Kitchen.Reader.as_range/1),
      b |> Enum.map(&String.to_integer/1)
    }
  end
end

defmodule Kitchen.Ingredients do
  def is_fresh?(ingredient, id_ranges) do
    count = id_ranges
    |> Enum.filter(fn range ->ingredient in range end)
    |> Enum.count_until(1)
    count == 1
  end

  def count_fresh(ingredients, id_ranges) do
    Enum.count(ingredients, &is_fresh?(&1, id_ranges))
  end

  defp can_merge?(range1, range2) do
    not Range.disjoint?(range1, range2) or range1.first == range2.last + 1
  end

  defp merge_ranges([]), do: []

  defp merge_ranges([first | rest]) do
    rest
    |> Enum.reduce([first], fn range, [last | acc] ->
      if can_merge?(range, last) do
        [Range.new(last.first, max(last.last, range.last)) | acc]
      else
        [range, last | acc]
      end
    end)
    |> Enum.reverse()
  end

  def count_fresh_ingredient_ids(id_ranges) do
    id_ranges
    |> Enum.sort_by(&(&1.first))
    |> merge_ranges()
    |> Enum.reduce(0, fn range, acc -> acc + Range.size(range) end)
  end
end


{id_ranges, ingredients} = Kitchen.Reader.read("input.example")
part1 = Kitchen.Ingredients.count_fresh(ingredients, id_ranges)
IO.puts("Part 1: #{part1}")

part2 = Kitchen.Ingredients.count_fresh_ingredient_ids(id_ranges)
IO.puts("Part 2: #{part2}")
