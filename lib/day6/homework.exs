defmodule Homework.Part1.Reader do
  def lines(path) do
    path
    |> File.stream!()
    # Strip newline
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    # Trim heading whitespaces
    |> Stream.map(&String.trim(&1))
    # Replace multiple spaces with a single one
    |> Stream.map(&String.replace(&1, ~r/ +/, " "))
    # Split on space
    |> Stream.map(&String.split(&1, " "))
  end

  def split_last(list) when length(list) > 0 do
    {all_but_last, [last]} = Enum.split(list, -1)
    {all_but_last, last}
  end

  defp as_integer_list(list) do
    list |> Enum.map(&String.to_integer/1)
  end

  def read(path) do
    list = path |> lines |> Enum.to_list()
    {numbers, operators} = split_last(list)

    columns =
      numbers
      |> Enum.map(&as_integer_list/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)

    {columns, operators}
  end
end

defmodule Homework.Part2.Reader do
  def zip_longest(lists) do
    max_length = lists |> Enum.map(&length/1) |> Enum.max(fn -> 0 end)

    0..(max_length - 1)
    |> Enum.map(fn index ->
      lists
      |> Enum.map(&Enum.at(&1, index))
      |> Enum.reject(&is_nil/1)
    end)
  end

  def split_last(list) when length(list) > 0 do
    {all_but_last, [last]} = Enum.split(list, -1)
    {all_but_last, last}
  end

  def split_by_spaces(values) do
    values
    |> Enum.chunk_by(fn val -> val == "" end)
    |> Enum.reject(fn val -> val == [""] end)
  end

  def as_integer_list(list) do
    list |> Enum.map(&String.to_integer/1)
  end

  def read(path) do
    lines =
      path
      |> File.stream!()
      |> Stream.map(&String.trim_trailing(&1, "\n"))
      |> Enum.to_list()

    {numbers, operators} = split_last(lines)

    # Transpose: convert rows to columns
    transposed =
      numbers
      # Split on every character
      |> Enum.map(&String.graphemes/1)
      # Transpose
      |> zip_longest()
      # Convert list of characters to a single item
      |> Enum.map(&Enum.join(&1, ""))
      # Trim extra whitespaces
      |> Enum.map(&String.trim/1)
      |> split_by_spaces()
      |> Enum.map(&as_integer_list/1)

    parsed_operators =
      operators
      |> String.replace(~r/ +/, " ")
      |> String.split(" ")

    {transposed, parsed_operators}
  end
end

defmodule Homework.Calculator do
  defp apply_operator(problem, "+"), do: Enum.sum(problem)
  defp apply_operator(problem, "*"), do: Enum.reduce(problem, 1, &Kernel.*/2)

  def calculate(numbers, operators) do
    Enum.zip(numbers, operators)
    |> Enum.map(fn {problem, operator} -> apply_operator(problem, operator) end)
    |> Enum.sum()
  end
end

{numbers, operators} = Homework.Part1.Reader.read("input.example")
Homework.Calculator.calculate(numbers, operators) |> IO.inspect(label: "Part 1")

{numbers, operators} = Homework.Part2.Reader.read("input.example")
Homework.Calculator.calculate(numbers, operators) |> IO.inspect(label: "Part 2")