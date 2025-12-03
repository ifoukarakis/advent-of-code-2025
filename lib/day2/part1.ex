
defmodule IDRange.Reader do
  defp lines(path) do
    path
    |> File.stream!
    |> Stream.map(&String.trim_trailing(&1, "\n") )
    |> Stream.flat_map(&String.split(&1, ","))
  end

  def range(str) do
    str
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end

  def read(path) do
    path
    |> lines()
    |> Stream.map(&range/1)
  end
end

defmodule IDRange.Validator do
  defp id_generator(id_range) do
    List.first(id_range)..List.last(id_range)
  end

  defp is_repetition?(value) do
    str = Integer.to_string(value)
    len = String.length(str)
    half = div(len, 2)

    rem(len, 2) == 0 and
      String.slice(str, 0, half) == String.slice(str, half, half)
  end

  def count_valid(id_range) do
    id_range
    |> id_generator
    |> Enum.sum_by(fn x -> if is_repetition?(x), do: x, else: 0 end)
  end
end


result = IDRange.Reader.read("input.example") |> Stream.map(&IDRange.Validator.count_valid/1) |> Enum.sum()
IO.puts("Total invalid IDs: #{result}")
