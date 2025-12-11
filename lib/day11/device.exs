defmodule Device.Reader do
  def read(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(&parse_line/1)
    |> Map.new()
  end

  defp parse_line(line) do
    [key, values] = String.split(line, ":", parts: 2)

    value_list =
      values
      |> String.trim()
      |> String.split()

    {String.trim(key), value_list}
  end
end

defmodule Device.Solver do
  def part1(devices) do
    count_paths(devices, "you", "out")
  end

  # Assumes graph is a DAG (no cycles) - memoize only on current node
  defp count_paths_dag(devices, current, destination, memo) do
    # If we reached the destination, this is one complete path
    if current == destination do
      {1, memo}
    else
      case Map.get(memo, current) do
        nil ->
          # Get the neighbors of the current node
          neighbors = Map.get(devices, current, [])

          # Explore all neighbors and sum the paths
          {total, final_memo} =
            Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc_count, acc_memo} ->
              {count, new_memo} = count_paths_dag(devices, neighbor, destination, acc_memo)
              {acc_count + count, new_memo}
            end)

          {total, Map.put(final_memo, current, total)}

        cached_count ->
          {cached_count, memo}
      end
    end
  end

  def part2(devices) do
    # Count paths with different node removals
    total = count_paths(devices, "svr", "out")
    without_dac = count_paths(remove_nodes(devices, ["dac"]), "svr", "out")
    without_fft = count_paths(remove_nodes(devices, ["fft"]), "svr", "out")
    without_both = count_paths(remove_nodes(devices, ["dac", "fft"]), "svr", "out")

    # Inclusion-exclusion: paths through BOTH
    total - without_dac - without_fft + without_both
  end

  defp remove_nodes(devices, nodes_to_remove) do
    devices
    |> Map.drop(nodes_to_remove)
    |> Enum.map(fn {node, neighbors} ->
      {node, Enum.reject(neighbors, &(&1 in nodes_to_remove))}
    end)
    |> Map.new()
  end

  defp count_paths(devices, source, destination) do
    {count, _memo} = count_paths_dag(devices, source, destination, %{})
    count
  end
end

Device.Reader.read("input.example.part1") |> Device.Solver.part1() |> IO.inspect(label: "Part 1", charlists: :as_lists)
Device.Reader.read("input.example.part2") |> Device.Solver.part2() |> IO.inspect(label: "Part 2", charlists: :as_lists)
