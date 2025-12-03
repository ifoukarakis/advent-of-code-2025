defmodule Joltage.Reader do
  defp lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  def parse_line(str) when is_binary(str) do
    String.graphemes(str)
    |> Enum.map(fn x ->
      {n, _} = Integer.parse(x)
      n
    end)
  end

  def read(path) do
    path
    |> lines()
    |> Stream.map(&parse_line/1)
  end
end

defmodule Joltage.Part1 do
  def greatest_two(digits) do
    # For each element, calculate the max element from that position to the end (excluding current)
    max_suffix =
      digits
      |> Enum.reverse()
      |> Enum.scan(&max/2)
      |> Enum.reverse()
      |> tl()  # Drop first element, shift by 1

    # Pair each digit with the max that comes after it
    digits
    |> Enum.drop(-1)
    |> Enum.zip(max_suffix)
    |> Enum.map(fn {first, max_after} -> first * 10 + max_after end)
    |> Enum.max()
  end


  def calculate(batteries) do
    batteries
    |> Enum.map(&greatest_two(&1))
    |> Enum.sum()
  end
end



defmodule Joltage.Part2 do

  def greatest_n_digit(digits, n) do
    total = length(digits)

    pick_digits(digits, n, 0, total)
    |> Enum.join()
    |> String.to_integer()
  end

  defp pick_digits(_digits, 0, _start, _total), do: []

  defp pick_digits(digits, remaining, start, total) do
    window_size = total - remaining - start + 1

    {max_digit, max_pos} =
      digits
      |> Enum.slice(start, window_size)
      |> Enum.with_index()
      |> Enum.max_by(fn {digit, _} -> digit end)

    [max_digit | pick_digits(digits, remaining - 1, start + max_pos + 1, total)]
  end

  def calculate(batteries) do
    batteries
    |> Enum.map(&greatest_n_digit(&1, 12))
    |> Enum.sum()
  end
end

result = Joltage.Reader.read("input.example") |> Joltage.Part1.calculate()
IO.puts("Part 1 result: #{result}")

result = Joltage.Reader.read("input.example") |> Joltage.Part2.calculate()
IO.puts("Part 2 result: #{result}")