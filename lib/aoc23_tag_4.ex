defmodule Aoc23_Tag_4 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_4.Parser_Tag_4

  @doc """
  Hello world.

  ## Examples

      iex> Aoc23.hello()
      :world

  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_4.txt")
    {:ok, cards, "", _, _, _} = Parser_Tag_4.input_tag_4(fileContents)

    map =
      cards
      |> accumulate_count_winning_numbers()

    map
    |> Map.values()
    |> Enum.map(&score/1)
    |> Enum.sum()
    |> IO.inspect()

    map
    |> Map.to_list()
    |> Enum.map(fn {key, amount} -> {key, {amount, 1}} end)
    |> Map.new()
    |> accumulate_copies(1, map |> Map.to_list() |> length)
    |> Map.values()
    |> Enum.map(fn {_, occurences} -> occurences end)
    |> Enum.sum()
    |> IO.inspect()

    {:ok, pid}
  end

  defp accumulate_copies(map, _, 0), do: map

  defp accumulate_copies(map, n, countdown) do
    {amount, occurences_of_card_n} = Map.fetch!(map, n)

    new_map =
      if amount > 0 do
        1..amount
        |> Range.to_list()
        |> List.foldl(map, fn k, map_acc ->
          update_map_if_has_key(map_acc, n + k, fn {amount, current_occurences} ->
            {amount, current_occurences + occurences_of_card_n}
          end)
        end)
      else
        map
      end

    accumulate_copies(new_map, n + 1, countdown - 1)
  end

  defp update_map_if_has_key(map, key, update) do
    if(Map.has_key?(map, key)) do
      Map.update!(map, key, update)
    else
      map
    end
  end

  defp accumulate_count_winning_numbers(cards) do
    cards
    |> Enum.map(&count_winning_numbers/1)
    |> Map.new()
  end

  defp count_winning_numbers(
         {{:game_nr, game_nr}, {:winning, winning_numbers}, {:drawn, numbers_drawn}}
       ) do
    amount =
      MapSet.intersection(MapSet.new(winning_numbers), MapSet.new(numbers_drawn))
      |> MapSet.size()

    {game_nr, amount}
  end

  defp score(amount) do
    if(amount == 0) do
      0
    else
      2 ** (amount - 1)
    end
  end

  defmodule Parser_Tag_4 do
    import NimbleParsec

    def collect([game_nr, winning_numbers, numbers_drawn]) do
      {{:game_nr, game_nr}, {:winning, winning_numbers}, {:drawn, numbers_drawn}}
    end

    numbers =
      integer(min: 1)
      |> ignore(repeat(string(" ")))
      |> repeat()
      |> wrap()

    eol =
      choice([
        string("\n"),
        string("\r\n")
      ])

    whitespace = repeat(string(" "))

    defparsec(
      :input_tag_4,
      ignore(string("Card"))
      |> ignore(whitespace)
      |> integer(min: 1)
      |> ignore(string(":"))
      |> ignore(whitespace)
      |> concat(numbers)
      |> ignore(string("|"))
      |> ignore(whitespace)
      |> concat(numbers)
      |> ignore(optional(eol))
      |> reduce(:collect)
      |> repeat()
    )
  end
end
