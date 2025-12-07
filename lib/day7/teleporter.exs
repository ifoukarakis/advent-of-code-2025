defmodule Teleporter.Reader do
  def read(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(&String.graphemes/1)
  end
end

defmodule Teleporter.Beams do
  # Part 1
  def tachyon_manifold([], positions, split_count) do
    {positions, split_count}
  end

  def tachyon_manifold([head | rest], positions, split_count) do
    {updated_positions, updated_split_count} =
      head
      |> Enum.with_index()
      |> Enum.reduce({positions, split_count}, fn {value, position},
                                                  {acc_positions, acc_split_count} ->
        case value do
          "S" ->
            {MapSet.put(acc_positions, position), acc_split_count}

          "^" ->
            if MapSet.member?(acc_positions, position) do
              new_positions =
                acc_positions
                |> MapSet.delete(position)
                |> MapSet.put(position - 1)
                |> MapSet.put(position + 1)

              {new_positions, acc_split_count + 1}
            else
              {acc_positions, acc_split_count}
            end

          _ ->
            {acc_positions, acc_split_count}
        end
      end)

    tachyon_manifold(rest, updated_positions, updated_split_count)
  end

  # Part 2
  def quantum_tachyon_manifold(room, position) do
    {result, _memo} = quantum_tachyon_manifold_with_memo(room, position, 0, %{})
    result
  end

  defp quantum_tachyon_manifold_with_memo(room, position, depth, memo)
       when depth >= length(room) do
    {1, Map.put(memo, {depth, position}, 1)}
  end

  defp quantum_tachyon_manifold_with_memo(room, position, depth, memo) do
    key = {depth, position}

    case Map.get(memo, key) do
      nil ->
        {result, new_memo} =
          case Enum.at(room, depth) |> Enum.at(position) do
            "^" ->
              {left, memo1} =
                quantum_tachyon_manifold_with_memo(room, position - 1, depth + 1, memo)

              {right, memo2} =
                quantum_tachyon_manifold_with_memo(room, position + 1, depth + 1, memo1)

              {left + right, memo2}

            _ ->
              quantum_tachyon_manifold_with_memo(room, position, depth + 1, memo)
          end

        {result, Map.put(new_memo, key, result)}

      cached ->
        {cached, memo}
    end
  end
end

room = Teleporter.Reader.read("input.example")
{_positions, splits} = Teleporter.Beams.tachyon_manifold(room, MapSet.new(), 0)
IO.puts("Part 1: #{splits}")

[entrance | rest_room] = room
[{_, position}] = entrance |> Enum.with_index() |> Enum.filter(fn {val, _index} -> val == "S" end)
timelines = Teleporter.Beams.quantum_tachyon_manifold(rest_room, position)
IO.puts("Part 2: #{timelines}")
