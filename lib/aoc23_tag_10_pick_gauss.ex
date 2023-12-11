defmodule Aoc23_Tag_10_Pick_Gauss do
  use Application

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_10.Parser_Tag_10

  import Aoc23_Tag_10

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_10.txt")
    {:ok, t, "", _, _, _} = Parser_Tag_10.input_tag_10(fileContents)

    {begin_j, begin_k} = find_beginning(t) |> dbg()

    pipes_with_steps =
      find_adjacent(t, [{begin_j, begin_k, 0}], %{{begin_j, begin_k} => 0})
      |> dbg()

    numbered_pipes =
      pipes_with_steps
      |> Map.keys()
      |> Enum.map(fn {j, k} -> {{j, k}, coord(t, j, k)} end)
      |> Map.new()
      |> enumerate_pipes(begin_j, begin_k, 0, %{})
      |> dbg()

    n = numbered_pipes |> map_size()

    numbered_pipes_cycle =
      numbered_pipes
      |> Map.put(-1, numbered_pipes |> Map.get(n - 1))
      |> Map.put(n, numbered_pipes |> Map.get(0))

    twice_the_area =
      0..(n - 1)
      |> Range.to_list()
      |> List.foldl(0, fn i, acc ->
        {x_i, _} = numbered_pipes_cycle |> Map.get(i)
        {_, y_ip1} = numbered_pipes_cycle |> Map.get(i + 1)
        {_, y_im1} = numbered_pipes_cycle |> Map.get(i - 1)

        acc + x_i * (y_ip1 - y_im1)
      end)
      |> abs()
      |> dbg()

    (div(twice_the_area - n, 2) + 1) |> dbg()

    {:ok, pid}
  end

  def enumerate_pipes(pipes, j, k, n, enumerateds) do
    case pipes |> Map.get({j, k}) do
      {:visited, :cross} ->
        enumerateds

      p when is_atom(p) ->
        dirs_from_here =
          p
          |> from_here()
          |> Enum.map(&dir_coords/1)
          |> Enum.map(fn {dir, dir_j, dir_k} ->
            new_j = j + dir_j
            new_k = k + dir_k

            can_get_here =
              case pipes |> Map.get({new_j, new_k}) do
                {:visited, :cross} ->
                  n > 1

                {:visited, _} ->
                  false

                new_field when is_atom(new_field) and not is_nil(new_field) ->
                  new_field
                  |> to_here()
                  |> Enum.any?(fn to_dir -> to_dir == dir end)

                nil ->
                  false
              end

            {new_j, new_k, can_get_here}
          end)
          |> Enum.filter(fn {_, _, can_get_here} -> can_get_here end)

        [{j_new, k_new, _} | _] = dirs_from_here

        enumerate_pipes(
          pipes |> Map.put({j, k}, {:visited, p}),
          j_new,
          k_new,
          n + 1,
          enumerateds |> Map.put(n, {j, k})
        )
    end
  end
end
