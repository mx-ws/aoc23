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

    pipes =
      find_adjacent(t, [{begin_j, begin_k, 0}], %{{begin_j, begin_k} => 0})
      |> dbg()

    Enum.max_by(pipes, fn {_jk, steps} -> steps end)
    |> dbg()

    t_fill_cross = fill_in_cross(t, pipes, begin_j, begin_k)

    outers =
      create_map(t_fill_cross, pipes)
      |> mark_outer(get_boundary(t_fill_cross))
      |> Enum.filter(fn {j, k} -> rem(j, 3) == 1 && rem(k, 3) == 1 end)
      |> length
      |> dbg()

    all_cells = length(t) * length(Enum.at(t, 0))

    all_pipes = pipes |> Map.values() |> length

    dbg({all_cells, all_pipes, outers})

    (all_cells - all_pipes - outers) |> dbg()

    {:ok, pid}
  end

  def mark_outer(map, left_to_check, marked \\ [])
  def mark_outer(_, [], marked), do: marked

  def mark_outer(map, [l | eft_to_check], marked) do
    case map |> Map.get(l) do
      :empty ->
        if marked |> Enum.any?(fn mark -> mark == l end) do
          mark_outer(map, eft_to_check, marked)
        else
          {j, k} = l

          mark_outer(
            map,
            [
              {j, k - 1},
              {j, k + 1},
              {j + 1, k},
              {j - 1, k}
            ] ++ eft_to_check,
            [l | marked]
          )
        end

      :pipe ->
        mark_outer(map, eft_to_check, marked)

      nil ->
        mark_outer(map, eft_to_check, marked)
    end
  end

  def fill_in_cross(t, pipes, begin_j, begin_k) do
    cond do
      Map.get(pipes, {begin_j - 1, begin_k}) && Map.get(pipes, {begin_j, begin_k - 1}) ->
        t |> List.replace_at(begin_j, t |> Enum.at(begin_j) |> List.replace_at(begin_k, :up_left))

      Map.get(pipes, {begin_j - 1, begin_k}) && Map.get(pipes, {begin_j, begin_k + 1}) ->
        t
        |> List.replace_at(begin_j, t |> Enum.at(begin_j) |> List.replace_at(begin_k, :up_right))

      Map.get(pipes, {begin_j + 1, begin_k}) && Map.get(pipes, {begin_j, begin_k - 1}) ->
        t
        |> List.replace_at(begin_j, t |> Enum.at(begin_j) |> List.replace_at(begin_k, :down_left))

      Map.get(pipes, {begin_j + 1, begin_k}) && Map.get(pipes, {begin_j, begin_k + 1}) ->
        t
        |> List.replace_at(
          begin_j,
          t |> Enum.at(begin_j) |> List.replace_at(begin_k, :down_right)
        )

      Map.get(pipes, {begin_j + 1, begin_k}) && Map.get(pipes, {begin_j - 1, begin_k}) ->
        t
        |> List.replace_at(begin_j, t |> Enum.at(begin_j) |> List.replace_at(begin_k, :up_down))

      Map.get(pipes, {begin_j, begin_k + 1}) && Map.get(pipes, {begin_j, begin_k - 1}) ->
        t
        |> List.replace_at(
          begin_j,
          t |> Enum.at(begin_j) |> List.replace_at(begin_k, :left_right)
        )
    end
  end

  def create_map(t, pipes, map \\ %{}) do
    dbg()

    0..(length(t) - 1)
    |> Range.to_list()
    |> List.foldl(map, fn j, map ->
      0..(length(Enum.at(t, 0)) - 1)
      |> Range.to_list()
      |> List.foldl(map, fn k, map ->
        case Map.get(pipes, {j, k}) do
          nil ->
            insert_empty_pipe(map, j, k)

          _ ->
            insert_pipe(map, coord(t, j, k), j, k)
        end
      end)
    end)
  end

  def get_boundary(t) do
    horizontal =
      for j <- [0, 3 * length(t) - 1], k <- 0..(3 * (t |> Enum.at(0) |> length) - 1) do
        {j, k}
      end

    vertical =
      for j <- 0..(3 * length(t) - 1), k <- [0, 3 * (t |> Enum.at(0) |> length) - 1] do
        {j, k}
      end

    horizontal ++ vertical
  end

  def insert_pipe(map, pipe, j, k) do
    if {j, k} == {1, 3} do
      {map, pipe, j, k} |> dbg()
    end

    case pipe do
      :up_left ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)

      :up_right ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)

      :down_left ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)

      :down_right ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)

      :left_right ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)

      :up_down ->
        map
        |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 0, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 1, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 1, 3 * k + 2}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
        |> Map.put({3 * j + 2, 3 * k + 1}, :pipe)
        |> Map.put({3 * j + 2, 3 * k + 2}, :empty)
    end
  end

  def insert_empty_pipe(map, j, k) do
    map
    |> Map.put({3 * j + 0, 3 * k + 0}, :empty)
    |> Map.put({3 * j + 0, 3 * k + 1}, :empty)
    |> Map.put({3 * j + 0, 3 * k + 2}, :empty)
    |> Map.put({3 * j + 1, 3 * k + 0}, :empty)
    |> Map.put({3 * j + 1, 3 * k + 1}, :empty)
    |> Map.put({3 * j + 1, 3 * k + 2}, :empty)
    |> Map.put({3 * j + 2, 3 * k + 0}, :empty)
    |> Map.put({3 * j + 2, 3 * k + 1}, :empty)
    |> Map.put({3 * j + 2, 3 * k + 2}, :empty)
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
      :up -> {:up, -1, 0}
      :down -> {:down, 1, 0}
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
      |> List.foldl(found, fn {j, k, step}, found_acc ->
        found_acc |> Map.put({j, k}, step)
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
        utf8_char([?7]) |> replace(:down_left),
        utf8_char([?F]) |> replace(:down_right),
        utf8_char([?J]) |> replace(:up_left),
        utf8_char([?L]) |> replace(:up_right),
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
