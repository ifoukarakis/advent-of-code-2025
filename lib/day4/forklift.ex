defmodule Forklift.Reader do
  def lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp line_to_coordinates({line, line_index}) do
    line
    |> String.graphemes()
    |> Stream.with_index()
    |> Stream.map(fn {char, char_index} ->
      {{line_index, char_index}, char}
    end)
  end

  def read(path) do
    path
    |> lines()
    |> Stream.with_index()
    |> Stream.flat_map(&line_to_coordinates/1)
    |> Map.new()
  end
end

defmodule Forklift.Counter do
  @target_char "@"
  @max_neighbors 3

  defp neighbors({row, col}) do
    [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row, col - 1},                     {row, col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]
  end

  defp count_at_neighbors(coordinate, grid_map) do
    coordinate
    |> neighbors()
    |> Enum.count(&(Map.get(grid_map, &1) == @target_char))
  end

  defp target_coords(grid_map) do
    for {coord, @target_char} <- grid_map, do: coord
  end

  defp movable?(coord, grid_map) do
    count_at_neighbors(coord, grid_map) <= @max_neighbors
  end

  def count_movable(grid_map) do
    grid_map
    |> target_coords()
    |> Enum.count(&movable?(&1, grid_map))
  end

  def count_deep_removable(grid_map), do: do_count_deep_removable(grid_map, 0)

  defp do_count_deep_removable(grid_map, acc) do
    movable_coords =
      grid_map
      |> target_coords()
      |> Enum.filter(&movable?(&1, grid_map))

    case movable_coords do
      [] -> acc
      coords -> do_count_deep_removable(Map.drop(grid_map, coords), acc + length(coords))
    end
  end
end


grid = Forklift.Reader.read("input.example")

part1 = Forklift.Counter.count_movable(grid)
IO.puts("Part 1: #{part1}")

part2 = Forklift.Counter.count_deep_removable(grid)
IO.puts("Part 2: #{part2}")