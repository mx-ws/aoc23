defmodule Aoc23_Tag_3 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_3.Parser_Tag_3

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_3.txt")
    {:ok, lines, "", _, _, _} = Parser_Tag_3.input_tag_3(fileContents)

    with_has_symbol =
      lines
      |> Enum.with_index(fn line, row_index ->
        line
        |> Enum.with_index(fn n, col_index ->
          check_adjacent(n, row_index, col_index, lines)
        end)
      end)

    with_has_symbol
    |> Enum.map(&numbers_with_symbol/1)
    |> List.flatten()
    |> Enum.sum()
    |> IO.inspect()

    with_has_symbol
    |> List.flatten()
    |> Enum.filter(fn x ->
      case x do
        {:star, [_, _]} -> true
        _ -> false
      end
    end)
    |> Enum.map(fn {:star, [k, n]} -> k * n end)
    |> Enum.sum()
    |> IO.inspect()

    {:ok, pid}
  end

  defp numbers_with_symbol(with_has_symbol) do
    numbers_with_symbol_acc(with_has_symbol, [], {:no_number})
  end

  defp numbers_with_symbol_acc(
         [],
         numbers_acc,
         current_number_acc
       ) do
    case(current_number_acc) do
      {:building_number, :encountered, n} -> [n | numbers_acc]
      {:building_number, :not_encountered, _} -> numbers_acc
      {:no_number} -> numbers_acc
    end
  end

  defp numbers_with_symbol_acc(
         [w | ith_has_symbol],
         numbers_acc,
         current_number_acc
       ) do
    case {w, current_number_acc} do
      {{has_symbol, n}, {:building_number, encountered_symbol, k}}
      when has_symbol == :has_symbol or has_symbol == :has_no_symbol ->
        numbers_with_symbol_acc(
          ith_has_symbol,
          numbers_acc,
          {:building_number,
           case has_symbol do
             :has_symbol -> :encountered
             :has_no_symbol -> encountered_symbol
           end, 10 * k + n}
        )

      {{has_symbol, n}, {:no_number}}
      when has_symbol == :has_symbol or has_symbol == :has_no_symbol ->
        numbers_with_symbol_acc(
          ith_has_symbol,
          numbers_acc,
          {:building_number,
           case has_symbol do
             :has_symbol -> :encountered
             :has_no_symbol -> :not_encountered
           end, n}
        )

      {_, {:building_number, :encountered, k}} ->
        numbers_with_symbol_acc(
          ith_has_symbol,
          [k | numbers_acc],
          {:no_number}
        )

      {_, _} ->
        numbers_with_symbol_acc(
          ith_has_symbol,
          numbers_acc,
          {:no_number}
        )
    end
  end

  defp check_adjacent(n, row_index, col_index, lines) when is_number(n) do
    has_symbol =
      accumulate_adjacents(row_index, col_index, lines)
      |> Enum.any?(fn n ->
        case n do
          {_, _, {:symbol, _}} -> true
          _ -> false
        end
      end)

    if has_symbol do
      {:has_symbol, n}
    else
      {:has_no_symbol, n}
    end
  end

  defp check_adjacent({:symbol, "*"}, row_index, col_index, lines) do
    digits =
      accumulate_adjacents(row_index, col_index, lines)
      |> Enum.filter(fn {_, _, n} -> is_number(n) end)

    numbers = acc_numbers(digits, lines, Map.new())

    {:star, numbers}
  end

  defp check_adjacent(n, _, _, _), do: n

  defp acc_numbers([{row, col, _} | igits], lines, map) do
    line = lines |> Enum.at(row)

    {new_col, number} = acc_numbers_help(col, line)
    new_map = Map.put_new(map, {row, new_col}, number)
    acc_numbers(igits, lines, new_map)
  end

  defp acc_numbers([], _lines, map) do
    Map.values(map)
  end

  defp acc_numbers_help(col, line) do
    if col == 0 do
      {0, number_from_here(line)}
    else
      case line |> Enum.at(col - 1) do
        n when is_number(n) ->
          acc_numbers_help(col - 1, line)

        _ ->
          {col, number_from_here(line |> Enum.slice(col..-1))}
      end
    end
  end

  defp number_from_here(line), do: number_from_here_acc(line, 0)

  defp number_from_here_acc([l | ine], n) when is_number(l) do
    number_from_here_acc(ine, 10 * n + l)
  end

  defp number_from_here_acc(_, n), do: n

  defp accumulate_adjacents(row_index, col_index, lines) do
    for row_adjacent <- [-1, 0, 1],
        col_adjacent <- [-1, 0, 1],
        row_adjacent != 0 or col_adjacent != 0 do
      current_row = row_index + row_adjacent
      current_col = col_index + col_adjacent

      adjacent_value_line =
        lines
        |> Enum.at(current_row)

      case adjacent_value_line do
        nil ->
          nil

        list ->
          {current_row, current_col, list |> Enum.at(current_col)}
      end
    end
  end

  defmodule Parser_Tag_3 do
    import NimbleParsec

    defp to_symbol(x), do: {:symbol, x}

    defparsec(
      :input_tag_3,
      choice([
        integer(1),
        utf8_char([?.]) |> replace(:dot),
        utf8_string([{:not, ?\n}], 1) |> map(:to_symbol)
      ])
      |> repeat()
      |> ignore(utf8_string([?\n], 1))
      |> wrap()
      |> repeat()
    )
  end
end
