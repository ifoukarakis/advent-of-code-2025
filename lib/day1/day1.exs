defmodule Dial do
  defstruct position: nil, count_zeros: nil

  def new() do
    %Dial{position: 50, count_zeros: 0}
  end


  def turn(dial, {direction, distance}) do
    new_position = do_turn(dial, {direction, distance})
    if new_position == 0 do
        %Dial{position: new_position, count_zeros: dial.count_zeros + 1}
    else
        %Dial{position: new_position, count_zeros: dial.count_zeros}
    end
  end

  defp do_turn(dial, {:left, distance})  do
    rem(rem(dial.position - distance, 100) + 100, 100)
  end

  defp do_turn(dial, {:right, distance}) do
    rem(dial.position + distance, 100)
  end
end


defmodule Dial.Instructions do
  defp lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp parse_side(str) when is_binary(str) do
    s = String.trim(str)
    dir = s |> String.at(0) |> String.upcase()
    digits = String.slice(s, 1..-1//1)
    {n, _} = Integer.parse(digits)
    if dir == "L", do: {:left, n}, else: {:right, n}
  end

  def read(path) do
    path
    |> lines()
    |> Stream.map(&parse_side/1)
  end
end

defmodule Dial.Runner do
  def run(path) do
    instructions = Dial.Instructions.read(path)

    dial = Dial.new()

    final_dial =
      Enum.reduce(instructions, dial, fn instruction, acc_dial ->
        Dial.turn(acc_dial, instruction)
      end)

    final_dial
  end
end


dial = Dial.Runner.run("input.example")
IO.puts("Final position: #{dial.position}")
IO.puts("Total times in position 0: #{dial.count_zeros}")
