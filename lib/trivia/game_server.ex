defmodule Trivia.GameServer do
  use GenServer
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
    Process.send_after(self(), :change_status, 10_000)
    {:noreply, game}
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
  def handle_info(:change_status, %Game{status: status} = game) when status == "waiting" do
    Process.send_after(self(), :change_question, 5_000)
    {:noreply, Game.change_status(game)}
  end

  @impl true
  def handle_info(:change_status, %Game{status: status} = game) when status == "finished" do
    {:noreply, Game.change_status(game)}
  end

  @impl true
  def handle_info(:change_question, %Game{status: status, questions: []} = game)
      when status == "playing" do
    {:noreply, Game.change_status(game)}
  end

  @impl true
  def handle_info(:change_question, %Game{status: status} = game)
      when status == "playing" do
    Process.send_after(self(), :change_question, 5_000)
    {:noreply, Game.change_question(game)}
  end
end
