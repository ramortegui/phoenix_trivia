defmodule Trivia.TriviaView do
  use Phoenix.LiveView

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.GameServer

  def render(assigns) do
    ~L"""
    <div class="">
    <%= if @in_game do %>
      Status: <%= @trivia.status %> <%= @trivia.counter %>
      <%= if @trivia.current_question do %>
        <div>
        <%= @trivia.current_question.text %>
        </div>
        <div>
        <%= @trivia.used_questions+1 %>/<%= @trivia.total_questions %>
        </div>
        <div>
        Options
        <%= for option <- @trivia.current_question.options do %>
          <button phx-click="submit_answer" phx-value="<%= option %>"><%= option %></button> <br/>
        <% end %>
        </div>
        </div>
        <% end %>
      <% else %>
      <div>
      <button phx-click="create_trivia" phx-value="Ruben">Create + Join</button>
      Number of trivias: <%= @number_of_trivias %>
      </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    if(connected?(socket), do: :timer.send_interval(500, self(), :tick))

    socket =
      socket
      |> assign(
        in_game: nil,
        trivia: nil,
        process: nil
      )
      |> number_of_trivias()

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    socket =
      if socket.assigns.in_game do
        update_game_info(socket)
      else
        update_info(socket)
      end

    {:noreply, socket}
  end

  def update_info(socket) do
    socket
    |> number_of_trivias()
  end

  def update_game_info(socket) do
    game_pid = socket.assigns.process

    socket =
      if is_pid(game_pid) and Process.alive?(game_pid) do
        socket
        |> update(:trivia, fn _trivia -> GameServer.game(game_pid) end)
      else
        socket
        |> assign(:in_game, false)
        |> assign(:process, nil)
      end

    socket
  end

  def handle_event("create_trivia", value, socket) do
    game = Game.new(%{name: "game1", player: Player.new(value)})
    {:ok, game_pid} = Trivia.DynamicSupervisor.start_child(game)
    GameServer.start_game(game_pid)

    socket =
      assign(socket, :trivia, GameServer.game(game_pid))
      |> number_of_trivias()

    socket = assign(socket, :in_game, true)
    socket = assign(socket, :process, game_pid)
    {:noreply, socket}
  end

  def handle_event("submit_answer", value, socket) do
    game_pid = socket.assigns.process

    socket =
      if is_pid(game_pid) and Process.alive?(game_pid) do
        socket
        |> update(:trivia, fn _trivia ->
          GameServer.submit_answer(game_pid, "Ruben", value)
          GameServer.game(game_pid)
        end)
      else
        socket
      end

    {:noreply, socket}
  end

  def number_of_trivias(socket) do
    nerds = DynamicSupervisor.count_children(Trivia.DynamicSupervisor)
    assign(socket, :number_of_trivias, nerds[:active])
  end
end
