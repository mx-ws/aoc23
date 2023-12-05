defmodule Aoc23_Tag_2 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_2.Parser_Tag_2

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_2.txt")
    {:ok, games, _, _, _, _} = Parser_Tag_2.input_tag_2(fileContents)

    maxes =
      games
      |> maxes_in_games()

    maxes
    |> maxes_below({12, 13, 14})
    |> Enum.sum()
    |> IO.puts()

    maxes
    |> Enum.map(fn {_game_nr, {red, green, blue}} -> red * green * blue end)
    |> Enum.sum()
    |> inspect()
    |> IO.puts()

    {:ok, pid}
  end

  defp maxes_below(maxes_map, {below_red, below_green, below_blue}) do
    Map.keys(maxes_map)
    |> Enum.filter(fn key ->
      case Map.fetch!(maxes_map, key) do
        {red, green, blue} ->
          red <= below_red &&
            green <= below_green &&
            blue <= below_blue
      end
    end)
  end

  defp maxes_in_games(games) do
    maxes_in_games_acc(games, %{})
  end

  defp maxes_in_games_acc([g | ames], map) do
    {game_nr, n} = maxes_in_game(g)
    new_map = Map.put(map, game_nr, n)
    maxes_in_games_acc(ames, new_map)
  end

  defp maxes_in_games_acc([], map), do: map

  defp maxes_in_game({game_nr, handfuls}) do
    {game_nr, maxes_in_game_acc(handfuls, {0, 0, 0})}
  end

  defp maxes_in_game_acc([h | andfuls], rgb) do
    new_rgb = add_handful_acc(h, rgb)
    maxes_in_game_acc(andfuls, new_rgb)
  end

  defp maxes_in_game_acc([], rgb), do: rgb

  defp add_handful_acc([{n, color} | handful], {red, green, blue}) do
    new_rgb =
      case color do
        "red" ->
          {max(red, n), green, blue}

        "green" ->
          {red, max(green, n), blue}

        "blue" ->
          {red, green, max(blue, n)}
      end

    add_handful_acc(handful, new_rgb)
  end

  defp add_handful_acc([], rgb), do: rgb

  defmodule Parser_Tag_2 do
    import NimbleParsec

    defp collect([x | xs]), do: {x, xs}
    defp to_pair([x, y]), do: {x, y}

    eol =
      choice([
        string("\n"),
        string("\r\n")
      ])

    ignore_whitespace =
      string(" ")
      |> ignore()
      |> repeat()

    colorname =
      choice([
        string("red"),
        string("green"),
        string("blue")
      ])

    one_color =
      integer(min: 1)
      |> concat(ignore_whitespace)
      |> concat(colorname)
      |> reduce(:to_pair)

    one_handful =
      one_color
      |> ignore(optional(string(", ")))
      |> repeat()
      |> wrap()

    handfuls =
      empty()
      |> concat(one_handful)
      |> ignore(string("; "))
      |> repeat()
      |> concat(one_handful)

    defparsec(
      :input_tag_2,
      ignore(string("Game "))
      |> integer(min: 1)
      |> ignore(string(": "))
      |> concat(handfuls)
      |> reduce(:collect)
      |> ignore(optional(eol))
      |> repeat()
    )
  end
end
