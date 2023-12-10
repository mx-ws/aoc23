defmodule Aoc23_Tag_10 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_10.Parser_Tag_10

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_10.txt")
    {:ok, t, "", _, _, _} = Parser_Tag_10.input_tag_10(fileContents)

    {begin_j, begin_k} = find_beginning(t) |> dbg()

    find_adjacent(t, [{begin_j, begin_k, 0}], %{{begin_j, begin_k} => 0})
    |> Enum.max_by(fn {_jk, steps} -> steps end)
    |> dbg()

    {:ok, pid}
  end

  def find_beginning(t) do
    t
    |> Enum.with_index()
    |> Enum.map(fn {line, index} -> {index, line |> Enum.find_index(fn x -> x == :cross end)} end)
    |> Enum.filter(fn {j, k} -> j && k end)
    |> Enum.at(0)
  end

  def from_here(pipe) do
    case pipe do
      :up_left -> [:up, :left]
      :up_right -> [:up, :right]
      :down_left -> [:down, :left]
      :down_right -> [:down, :right]
      :left_right -> [:left, :right]
      :up_down -> [:up, :down]
      :cross -> [:up, :down, :left, :right]
      :field -> []
    end
  end

  def to_here(pipe) do
    pipe
    |> from_here()
    |> Enum.map(&invert/1)
  end

  def invert(dir) do
    case dir do
      :up -> :down
      :down -> :up
      :left -> :right
      :right -> :left
    end
  end

  def dir_coords(dir) do
    case dir do
      :up -> {:up, 1, 0}
      :down -> {:down, -1, 0}
      :left -> {:left, 0, -1}
      :right -> {:right, 0, 1}
    end
  end

  def find_adjacent(t, [{j, k, step} | jks], found) do
    dirs_from_here =
      t
      |> coord(j, k)
      |> from_here()
      |> Enum.map(&dir_coords/1)
      |> Enum.map(fn {dir, dir_j, dir_k} ->
        new_j = j + dir_j
        new_k = k + dir_k

        can_get_here =
          t
          |> coord(new_j, new_k)
          |> to_here()
          |> Enum.any?(fn to_dir -> to_dir == dir end)

        {new_j, new_k, can_get_here}
      end)
      |> Enum.filter(fn {new_j, new_k, can_get_here} when is_boolean(can_get_here) ->
        can_get_here &&
          Enum.all?(found, fn {{found_j, found_k}, found_step} ->
            found_j != new_j || found_k != new_k || found_step > step + 1
          end)
      end)
      |> Enum.map(fn {new_j, new_k, _} -> {new_j, new_k, step + 1} end)

    new_found =
      dirs_from_here
      |> List.foldl(found, fn {j, k, step}, acc ->
        found |> Map.put({j, k}, step)
      end)

    find_adjacent(t, dirs_from_here ++ jks, new_found)
  end

  def find_adjacent(_, [], found), do: found

  def coord(t, j, k) do
    t
    |> Enum.at(j)
    |> Enum.at(k)
  end

  defmodule Parser_Tag_10 do
    import NimbleParsec

    defparsec(
      :input_tag_10,
      choice([
        utf8_char([?7]) |> replace(:up_left),
        utf8_char([?F]) |> replace(:up_right),
        utf8_char([?J]) |> replace(:down_left),
        utf8_char([?L]) |> replace(:down_right),
        utf8_char([?-]) |> replace(:left_right),
        utf8_char([?|]) |> replace(:up_down),
        utf8_char([?S]) |> replace(:cross),
        utf8_char([?.]) |> replace(:field)
      ])
      |> times(min: 1)
      |> wrap()
      |> ignore(optional(utf8_char([?\n])))
      |> repeat()
    )
  end
end
