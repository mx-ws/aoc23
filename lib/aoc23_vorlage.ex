defmodule Aoc23_Tag_ do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """

  @doc """
  start
  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    fileContents = File.read!("input_tag_4.txt")
    {:ok, data, "", _, _, _} = Parser_Tag_.input_tag_(fileContents)
    # do Stuff

    {:ok, pid}
  end

  defmodule Parser_Tag_ do
    import NimbleParsec

    defparsec(
      :input_tag_,
      repeat(string(""))
    )
  end
end
