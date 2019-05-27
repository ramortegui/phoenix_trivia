defmodule Trivia.DynamicSupervisor do
  @moduledoc """
  Dynamic supervisor used to create trivia games on demand.
  """
  use DynamicSupervisor

  alias Trivia.Game
  alias Trivia.GameServer

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(%Game{} = game) do
    # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar,
    spec = {GameServer, game}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
