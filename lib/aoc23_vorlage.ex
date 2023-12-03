defmodule Aoc23_Tag_ do
  use Application

  import NimbleParsec

  @moduledoc """
  Documentation for `Aoc23`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc23.hello()
      :world

  """
  def start(_type, _args) do
    children = []

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

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
