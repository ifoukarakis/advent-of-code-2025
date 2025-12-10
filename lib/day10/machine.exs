defmodule Machine.Reader do
  def read(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Extract the parts using regex
    bracket_pattern = ~r/\[([.#]+)\]/
    paren_pattern = ~r/\(([0-9,]+)\)/
    brace_pattern = ~r/\{([0-9,]+)\}/

    # Parse [] part - convert . to false, # to true
    [_, bracket_content] = Regex.run(bracket_pattern, line)
    booleans =
      bracket_content
      |> String.graphemes()
      |> Enum.map(fn
        "." -> false
        "#" -> true
      end)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {val, idx} -> {idx,val} end)

    # Parse all () parts - each becomes a list of integers
    parens =
      Regex.scan(paren_pattern, line)
      |> Enum.map(fn [_, content] -> parse_integers(content) end)

    # Parse {} part - becomes a list of integers
    [_, brace_content] = Regex.run(brace_pattern, line)
    braces = parse_integers(brace_content)

    {booleans, parens, braces}
  end

  defp parse_integers(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Machine.Solver do
  def part1(problems) do
    # Create ETS table for memoization once
    :ets.new(:memo, [:set, :public, :named_table])

    result =
      problems
      |> Enum.map(fn problem ->
        :ets.delete_all_objects(:memo)  # Clear cache between problems
        solve_part1(problem)
      end)
      |> Enum.sum()

    :ets.delete(:memo)
    result
  end

  def solve_part1({target, buttons, _}) do
    # Create a state map with everything equal to false
    initial_state =
      0..(map_size(target) - 1)
      |> Enum.into(%{}, fn idx -> {idx, false} end)

    search(initial_state, target, buttons)
  end

  defp search(state, target, _) when state == target do
    0
  end

  defp search(state, target, buttons) do
    case :ets.lookup(:memo, state) do
      [{_, cached}] ->
        cached

      [] ->
        # Mark as being computed (cycle detection)
        :ets.insert(:memo, {state, :computing})

        result =
          buttons
          |> Enum.map(fn button ->
            case search(apply_button(state, button), target, buttons) do
              n when is_integer(n) -> 1 + n
              _ -> :infinity
            end
          end)
          |> Enum.min()

        # Cache the result
        :ets.insert(:memo, {state, result})
        result
    end
  end

  defp apply_button(state, button) do
    # Toggle each index specified in the button
    button
    |> Enum.reduce(state, fn idx, acc ->
      Map.update!(acc, idx, &(!&1))
    end)
  end

end

Machine.Reader.read("input.example")  |> Machine.Solver.part1() |> IO.inspect(label: "Part 1", charlists: :as_lists)
