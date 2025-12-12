defmodule Present.Reader do
  def read(path) do
    lines =
      path
      |> File.read!()
      |> String.split("\n")

    {shapes, boxes} = parse_sections(lines)
    %{shapes: shapes, boxes: boxes}
  end

  defp parse_sections(lines) do
    # Split into shape definitions and box specifications
    {shape_lines, box_lines} = Enum.split_while(lines, fn line ->
      !String.contains?(line, "x")
    end)

    shapes = parse_shapes(shape_lines)
    boxes = parse_boxes(box_lines)

    {shapes, boxes}
  end

  defp parse_shapes(lines) do
    lines
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.filter(fn chunk -> length(chunk) > 0 end)
    |> Enum.map(&parse_shape/1)
    |> Enum.into(%{})
  end

  defp parse_shape([header | grid_lines]) do
    index = header |> String.trim_trailing(":") |> String.to_integer()

    # Parse the grid, converting # to 1 and . to 0
    grid =
      grid_lines
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.map(fn char -> if char == "#", do: 1, else: 0 end)
      end)

    {index, grid}
  end

  defp parse_boxes(lines) do
    lines
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_box/1)
  end

  defp parse_box(line) do
    [dimensions, quantities] = String.split(line, ":", parts: 2)
    [width, height] = dimensions |> String.split("x") |> Enum.map(&String.to_integer/1)

    # Parse quantities for each shape index
    shape_quantities =
      quantities
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {quantity, index} -> {index, quantity} end)

    %{width: width, height: height, quantities: shape_quantities}
  end
end

defmodule Present.Solver do
  def part1(%{shapes: shapes, boxes: boxes}) do
    boxes
    |> Enum.count(&can_fit_all_presents?(&1, shapes))
  end

  def can_fit_all_presents?(box, shapes) do
    can_fit_parts?(box, shapes)
  end

  defp can_fit_parts?(box, shapes) do
    # Count total # cells needed across all shapes
    total_cells =
      box.quantities
      |> Enum.map(fn {shape_idx, count} ->
        shape = shapes[shape_idx]
        cells_per_shape = shape |> Enum.map(&Enum.sum/1) |> Enum.sum()
        count * cells_per_shape
      end)
      |> Enum.sum()

    # Check if total # cells fit in the area
    area = box.width * box.height
    total_cells <= area
  end

end

data = Present.Reader.read("input.example")

data |> Present.Solver.part1() |> IO.inspect(label: "Part 1")
