defmodule Aoc23_Tag_1 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_1.Tag_1_Parser

  @doc """
  Hello world.

  ## Examples

      iex> Aoc23.hello()
      :world

  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_1.txt")
    {:ok, result, _, _, _, _} = Tag_1_Parser.input_tag_1(fileContents)
    # IO.puts(inspect(result, charlists: :as_lists))
    IO.puts(inspect(List.foldl(result, 0, fn x, y -> x + y end)))

    {:ok, pid}
  end

  defmodule Tag_1_Parser do
    alias List.Chars
    import NimbleParsec

    defp collect(xs), do: 10 * List.first(xs) + List.last(xs)

    eol =
      choice([
        string("\n"),
        string("\r\n")
      ])

    defparsec(
      :input_tag_1,
      repeat(
        choice([
          integer(1),
          string("z") |> lookahead(string("ero")) |> replace(0),
          string("o") |> lookahead(string("ne")) |> replace(1),
          string("t") |> lookahead(string("wo")) |> replace(2),
          string("t") |> lookahead(string("hree")) |> replace(3),
          string("f") |> lookahead(string("our")) |> replace(4),
          string("f") |> lookahead(string("ive")) |> replace(5),
          string("s") |> lookahead(string("ix")) |> replace(6),
          string("s") |> lookahead(string("even")) |> replace(7),
          string("e") |> lookahead(string("ight")) |> replace(8),
          string("n") |> lookahead(string("ine")) |> replace(9),
          ignore(utf8_char([{:not, ?0..?9}, {:not, ?\n}]))
        ])
      )
      |> ignore(eol)
      |> reduce(:collect)
      |> repeat()
    )
  end
end
