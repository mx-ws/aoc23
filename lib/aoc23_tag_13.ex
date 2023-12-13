defmodule Aoc23_Tag_13 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_13.Parser_Tag_13

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_13.txt")
    {:ok, data, rest, _, _, _} = Parser_Tag_13.input_tag_13(fileContents)

    {data, rest} |> dbg()

    data
    |> Enum.map(&pattern_score/1)
    |> Enum.sum()
    |> dbg()

    {:ok, pid}
  end

  def pattern_score(pattern) do
    transposed = transpose_list_of_lists(pattern)

    case(is_symmetric(transposed)) do
      {true, at_line} ->
        at_line

      false ->
        {true, at_line} = is_symmetric(pattern)
        at_line * 100
    end
  end

  def is_symmetric(lines, acc \\ [], at_line \\ 0)
  def is_symmetric([l | ines], [], at_line), do: is_symmetric(ines, [l], at_line + 1)
  def is_symmetric([], _acc, _at_line), do: false

  def is_symmetric([l | ines], [a | cc], at_line) do
    if(
      Enum.zip([l | ines], [a | cc])
      |> List.foldl(true, fn {a, b}, acc -> a == b && acc end)
    ) do
      {true, at_line}
    else
      is_symmetric(ines, [l | [a | cc]], at_line + 1)
    end
  end

  def transpose_list_of_lists(pattern) do
    map =
      pattern
      |> Enum.with_index(fn line, j -> {j, line} end)
      |> List.foldl(%{}, fn {j, line}, map ->
        line
        |> String.to_charlist()
        |> Enum.with_index(fn char, k -> {k, char} end)
        |> List.foldl(map, fn {k, char}, map -> map |> Map.put({j, k}, char) end)
      end)

    0..((pattern |> Enum.at(0) |> String.to_charlist() |> length) - 1)
    |> Enum.map(fn j ->
      0..((pattern |> length) - 1)
      |> Enum.map(fn k ->
        map |> Map.get({k, j})
      end)
    end)
  end

  defmodule Parser_Tag_13 do
    import NimbleParsec

    defparsec(
      :input_tag_13,
      utf8_string([{:not, ?\n}], min: 1)
      |> ignore(optional(utf8_char([?\n])))
      |> times(min: 1)
      |> wrap()
      |> ignore(optional(utf8_char([?\n])))
      |> times(min: 1)
    )
  end
end
