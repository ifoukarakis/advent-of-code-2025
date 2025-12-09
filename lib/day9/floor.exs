defmodule Floor.Reader do

  def as_integer_list(list) do
    list |> Enum.map(&Integer.parse/1)
  end

  def strings_to_integers(list) do
    list |> Enum.map(&String.to_integer/1)
  end

  def read(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> strings_to_integers()
      |> List.to_tuple()
    end)
  end
end


defmodule Floor.Solver do
  def all_pairs(tiles) do
    for a <- tiles, b <- tiles, a != b, do: {a, b}
  end

  def area({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
  end

  def intersect?({{x1a, y1a}, {x2a, y2a}}, {{x1b, y1b}, {x2b, y2b}}) do
    al = min(x1a, x2a)
    ar = max(x1a, x2a)
    at = min(y1a, y2a)
    ab = max(y1a, y2a)

    bl = min(x1b, x2b)
    br = max(x1b, x2b)
    bt = min(y1b, y2b)
    bb = max(y1b, y2b)

    al < br and ar > bl and at < bb and ab > bt
  end

  def part1(tiles) do
    tiles
    |> all_pairs()
    |> Enum.map(fn {a, b} -> area(a, b) end)
    |> Enum.max()
  end

  def part2(tiles) do
    # Create edge rectangles from consecutive tile pairs (wrapping around)
    edges = tiles
    |> Enum.chunk_every(2, 1, tiles)
    |> Enum.map(fn [a, b] -> {a, b} end)

    # Find the largest rectangle that doesn't intersect with any edge
    tiles
    |> all_pairs()
    |> Enum.reduce(0, fn rect, max_area ->
      current_area = area(elem(rect, 0), elem(rect, 1))

      if current_area > max_area and not Enum.any?(edges, &intersect?(rect, &1)) do
        current_area
      else
        max_area
      end
    end)
  end
end

Floor.Reader.read("input.example") |> Floor.Solver.part1() |> IO.inspect(label: "Part 1", charlists: :as_lists)
Floor.Reader.read("input.example") |> Floor.Solver.part2() |> IO.inspect(label: "Part 2", charlists: :as_lists)
