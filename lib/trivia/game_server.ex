defmodule Trivia.GameServer do
  @moduledoc """
  Maintain and control timer and messages for processes managing trivias.
  """
  use GenServer, restart: :transient

  alias Trivia.Game
  alias Trivia.Player

  # Client

  def start_link(%Game{} = default) do
    GenServer.start_link(__MODULE__, default)
  end

  def game(pid) do
    GenServer.call(pid, :game)
  end

  def start_game(pid) do
    GenServer.cast(pid, :start_game)
  end

  def add_player(pid, %Player{} = player) do
    GenServer.cast(pid, {:add_player, player})
  end

  def submit_answer(pid, name, answer) do
    GenServer.cast(pid, {:submit_answer, name, answer})
  end

  # Server (callbacks)

  @impl true
  def init(default) do
    {:ok, default}
  end

  @impl true
  def handle_call(:game, _from, %Game{} = game) do
    {:reply, game, game}
  end

  @impl true
  def handle_cast(:start_game, %Game{} = game) do
    check_timer(1_000)
    {:noreply, Game.start_game(game)}
  end

  @impl true
  def handle_cast({:add_player, %Player{} = player}, %Game{} = game) do
    {:noreply, Game.add_player(game, player)}
  end

  @impl true
  def handle_cast({:submit_answer, name, answer}, %Game{players: players} = game) do
    case Enum.find(players, &(&1.name == name)) do
      %Player{} = player ->
        {:noreply, Game.check_answer(game, player, answer)}

      nil ->
        {:noreply, game}
    end
  end

  @impl true
  def handle_info(:change_status, %Game{} = game) do
    {:noreply, Game.change_status(game)}
  end

  @impl true
  def handle_info(:change_question, %Game{} = game) do
    {:noreply, Game.change_question(game)}
  end

  @impl true
  def handle_info(:check_timer, %Game{counter: counter} = game)
      when counter > 0 do
    check_timer()
    {:noreply, Game.decrement_counter(game)}
  end

  @impl true
  def handle_info(:check_timer, %Game{counter: counter, status: status} = game)
      when counter <= 0 do
    game =
      case status do
        "waiting" ->
          Game.change_status(game)

        "playing" ->
          Game.change_question(game)

        "finished" ->
          Process.exit(self(), :shutdown)
      end

    check_timer()

    {:noreply, game}
  end

  defp check_timer(time \\ 1000) do
    Process.send_after(self(), :check_timer, time)
  end
end
