defmodule Aoc23_Tag_16 do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """
  alias Aoc23_Tag_16.Parser_Tag_16

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_16.txt")
    {:ok, data, "", _, _, _} = Parser_Tag_16.input_tag_16(fileContents)

    visiteds =
      visiteds([{0, 0, {0, 1}}], data, %{})
      |> dbg()

    for j <- 0..9 do
      for k <- 0..9 do
        if visiteds |> Map.has_key?({j, k}) do
          ~c"#"
        else
          ~c"."
        end
      end ++ ~c"\n"
    end
    |> List.flatten()
    |> IO.puts()

    visiteds |> map_size() |> IO.puts()

    {:ok, pid}
  end

  def visiteds([], _data, visited), do: visited

  def visiteds([{j, k, dir} | positions], data, visited) do
    {j, k, dir} |> dbg()

    cell =
      data
      |> Enum.at(j)
      |> Enum.at(k)

    new_dirs =
      transform_dir(dir, cell)
      |> Enum.map(fn {j_dir, k_dir} -> {j + j_dir, k + k_dir, {j_dir, k_dir}} end)
      |> Enum.filter(fn pos ->
        {new_j, new_k, dir} = pos

        new_j >= 0 &&
          new_k >= 0 &&
          new_j < length(data) &&
          new_k < length(data |> Enum.at(0)) &&
          !(visited
            |> Map.get({new_j, new_k}, MapSet.new())
            |> MapSet.member?(dir))
      end)

    new_visited =
      visited
      |> Map.update({j, k}, MapSet.new([dir]), fn m ->
        m |> MapSet.put(m)
      end)

    visiteds(new_dirs ++ positions, data, new_visited)
  end

  def transform_dir({j, k}, cell) do
    case cell do
      ?/ ->
        [{-k, -j}]

      ?\\ ->
        [{k, j}]

      ?- ->
        if k == 0 do
          [{0, 1}, {0, -1}]
        else
          [{j, k}]
        end

      ?| ->
        if k == 0 do
          [{j, k}]
        else
          [{1, 0}, {-1, 0}]
        end

      ?. ->
        [{j, k}]
    end
  end

  defmodule Parser_Tag_16 do
    import NimbleParsec

    defparsec(
      :input_tag_16,
      choice([
        utf8_char([?/]),
        utf8_char([?\\]),
        utf8_char([?-]),
        utf8_char([?|]),
        utf8_char([?.])
      ])
      |> times(min: 1)
      |> wrap()
      |> ignore(optional(utf8_char([?\n])))
      |> times(min: 1)
    )
  end
end
