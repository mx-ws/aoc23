defmodule Aoc23_Tag_5 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_5.Parser_Tag_5

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_5.txt")
    {:ok, [seeds, maps], "", _, _, _} = Parser_Tag_5.input_tag_5(fileContents)

    seeds
    |> Enum.map(&sequential_look_up(&1, maps))
    |> Enum.min()
    |> dbg()

    look_up_all_seeds(seeds, maps, :infinity) |> dbg()

    {:ok, pid}
  end

  defp sequential_look_up(seed, [m | aps]) do
    # {map_name, _} = m

    # dbg({seed, map_name})

    look_up!(m, seed)
    |> sequential_look_up(aps)
  end

  defp sequential_look_up(seed, []), do: seed

  defp look_up_all_seeds([], _maps, current_min), do: current_min

  defp look_up_all_seeds([s | [e | edrange]], maps, current_min) do
    all_look_ups_min =
      List.foldl(maps, [{s, e}], fn m, ses ->
        {name, _} = m
        IO.inspect({name, s, e})

        ses
        |> Enum.map(fn se ->
          look_up_range(m, [se], [])
        end)
        |> List.flatten()
        |> Enum.sort_by(fn {from, _len} -> from end)
        |> (fn rs ->
              c = combine_ranges(rs, [])

              dbg(c, limit: :infinity)
              c
            end).()
      end)
      |> Enum.map(fn {from, _len} -> from end)
      |> Enum.min()
      |> IO.inspect()

    # dbg({all_look_ups_min, s, e})

    look_up_all_seeds(edrange, maps, min(all_look_ups_min, current_min))
  end

  defp combine_ranges([r | anges], accum) do
    new_accum = combine(r, accum)
    combine_ranges(anges, new_accum)
  end

  defp combine_ranges([], accum), do: accum

  defp combine({from, len}, [{from_acc, len_acc} | ccum]) do
    if(from <= from_acc + len_acc - 1) do
      [{from_acc, len + from - from_acc} | ccum]
    else
      [{from_acc, len_acc} | combine({from, len}, ccum)]
    end
  end

  defp combine(r, []), do: [r]

  def look_up_range({map_name, [{value, current_key, range} | ranges]}, seed_ranges, acc) do
    look_up_further =
      seed_ranges
      |> Enum.map(fn {from, length} ->
        to = from + length - 1

        [
          {from, min(current_key - 1, to)},
          {max(current_key + range, from), to}
        ]
        |> Enum.filter(fn {x, y} -> x <= y end)
        |> Enum.map(fn {x, y} -> {x, y - x + 1} end)
      end)
      |> List.flatten()

    looked_up =
      seed_ranges
      |> Enum.map(fn {from, length} ->
        to = from + length - 1

        [
          {max(current_key, from) + value - current_key,
           min(current_key + range - 1, to) + value - current_key}
        ]
        |> Enum.filter(fn {x, y} -> x <= y end)
        |> Enum.map(fn {x, y} -> {x, y - x + 1} end)
      end)
      |> List.flatten()

    look_up_range({map_name, ranges}, look_up_further, looked_up ++ acc)
  end

  def look_up_range({_map_name, []}, seed_ranges, acc), do: seed_ranges ++ acc

  defp look_up!({map_name, [{value, current_key, range} | ranges]}, look_up_key) do
    if(current_key <= look_up_key && look_up_key < current_key + range) do
      value + look_up_key - current_key
    else
      look_up!({map_name, ranges}, look_up_key)
    end
  end

  defp look_up!({_map_name, []}, key), do: key

  defmodule Parser_Tag_5 do
    import NimbleParsec

    defp triple([key, value, range]), do: {key, value, range}
    defp named([name | maps]), do: {name, maps}

    intse =
      ignore(optional(string(" ")))
      |> integer(min: 1)
      |> times(min: 1)

    map_name = utf8_string([{:not, ?:}, {:not, ?\s}], min: 1)

    seeds =
      ignore(string("seeds: "))
      |> concat(intse)
      |> wrap()

    maps =
      map_name
      |> ignore(optional(string(" map")))
      |> ignore(string(":"))
      |> ignore(optional(string("\n")))
      |> repeat(intse |> reduce(:triple) |> ignore(repeat(string("\n"))))
      |> ignore(repeat(string("\n")))
      |> reduce(:named)
      |> repeat()
      |> wrap()

    defparsec(
      :input_tag_5,
      seeds
      |> ignore(repeat(string("\n")))
      |> concat(maps)
    )
  end
end
