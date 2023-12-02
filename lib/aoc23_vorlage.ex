defmodule Aoc23 do
  use Application

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
end
