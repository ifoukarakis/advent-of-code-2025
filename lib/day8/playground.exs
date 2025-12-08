defmodule JunctionBox.Reader do
  def read(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn x -> x |> Enum.map(&String.to_integer/1) end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {list, idx} -> {idx, list} end)
  end
end


defmodule JunctionBox.Solver do

  def all_pairs(boxes) do
    size = map_size(boxes)
    for a <- 0..(size - 1), b <- 0..(size - 1), a < b, do: {a, b}
  end

  def distance(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {x1, x2} -> (x1 - x2) * (x1 - x2) end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  def distances(boxes) do
    boxes
    # Find all box pairs
    |> all_pairs
    # Calculate distance for each combination
    |> Enum.map(fn {a, b} -> {{a, b}, distance(boxes[a], boxes[b])} end)
    # Sort by distance
    |> Enum.sort_by(fn {_, dist} -> dist end)
  end

  defp merge_circuits(circuits, circuit_a, circuit_b) do
    Enum.map(circuits, fn {box, circ} ->
      {box, if(circ == circuit_b, do: circuit_a, else: circ)}
    end)
    |> Map.new()
  end

  def part1(boxes, num_connections) do
    n = map_size(boxes)

    boxes
    |> distances()
    |> Enum.take(num_connections)
    |> Enum.reduce(Map.new(0..(n - 1), fn i -> {i, i} end), fn {{a, b}, _}, circuits ->
      circuit_a = circuits[a]
      circuit_b = circuits[b]

      if circuit_a == circuit_b do
        circuits
      else
        merge_circuits(circuits, circuit_a, circuit_b)
      end
    end)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2(boxes) do
    n = map_size(boxes)

    {_circuits, {a, b}} =
      boxes
      |> distances()
      |> Enum.reduce_while({Map.new(0..(n - 1), fn i -> {i, i} end), nil}, fn {{a, b}, _}, {circuits, _} ->
        circuit_a = circuits[a]
        circuit_b = circuits[b]

        if circuit_a == circuit_b do
          {:cont, {circuits, nil}}
        else
          new_circuits = merge_circuits(circuits, circuit_a, circuit_b)
          num_circuits = new_circuits |> Map.values() |> Enum.uniq() |> length()

          if num_circuits == 1 do
            {:halt, {new_circuits, {a, b}}}
          else
            {:cont, {new_circuits, {a, b}}}
          end
        end
      end)

    [x1 | _] = boxes[a]
    [x2 | _] = boxes[b]
    x1 * x2
  end
end

# Use 10 for example, 1000 for your input
JunctionBox.Reader.read("input.example") |> JunctionBox.Solver.part1(10) |> IO.inspect(label: "Part 1")
JunctionBox.Reader.read("input.example") |> JunctionBox.Solver.part2() |> IO.inspect(label: "Part 2")