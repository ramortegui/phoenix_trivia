defmodule Trivia.TriviaView do
  use Phoenix.LiveView

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.GameServer

  def render(assigns) do
    ~L"""
    <div class="">
      <%= if @in_game do %>
        <div>
            <button phx-click="return-main">Return</button>
        </div>
        <div>
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
            <div>
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
          <%= for trivia <- @available_trivias do %>
            <button phx-click="join_trivia" phx-value=<%= elem(trivia,0) %>>Join</button>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    if(connected?(socket), do: :timer.send_interval(100, self(), :tick))

    socket =
      socket
      |> assign(
        in_game: false,
        trivia: nil,
        process: nil,
        number_of_trivias: 0,
        available_trivias: [],
        display_game: false
      )

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, update_game_info(socket)}
  end

  def update_game_info(socket) do
    game_pid = socket.assigns.process
    game = socket.assigns.trivia
    in_game = socket.assigns.in_game

    if game == nil do
      trivias(socket)
    else
      game = GameServer.game(game_pid)

      if game.status == "destroy" and game.counter == 0 do
        IO.puts("need to kill")
        IO.puts(in_game)

        assign(socket, :trivia, nil)
        |> update(:in_game, fn _ -> false end)
      else
        assign(socket, :trivia, game)
      end
    end
  end

  def old_update_game_info(socket) do
    game_pid = socket.assigns.process

    if is_pid(game_pid) and Process.alive?(game_pid) do
      game = GameServer.game(game_pid)

      if game.status == "destroy" do
        socket
        |> assign(:in_game, false)
      else
        assign(socket, :trivia, game)
      end
    else
      socket
      |> clean_game()
      |> trivias()
    end
  end

  def handle_event("create_trivia", value, socket) do
    game = Game.new(%{name: value, player: Player.new(value)})
    {:ok, game_pid} = Trivia.DynamicSupervisor.start_child(game)
    GameServer.start_game(game_pid)
    {:noreply, assign_game(socket, game_pid)}
  end

  def handle_event("join_trivia", value, socket) do
    game_pid = Map.get(socket.assigns.available_trivias, String.to_integer(value))

    {:noreply, assign_game(socket, game_pid)}
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
        |> assign(:in_game, false)
      end

    {:noreply, socket}
  end

  def handle_event("return-main", _value, socket) do
    {:noreply, assign(socket, :ingame, false)}
  end

  def assign_game(socket, game_pid) do
    socket
    |> assign(:trivia, GameServer.game(game_pid))
    |> assign(:process, game_pid)
    |> assign(:in_game, true)
  end

  def clean_game(socket) do
    socket
    |> assign(:trivia, nil)
    |> assign(:process, nil)
    |> assign(:in_game, false)
  end

  def trivias(socket) do
    childs = DynamicSupervisor.which_children(Trivia.DynamicSupervisor)

    available_trivias =
      childs
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        {_, pid, _, _} = value
        {index, pid}
      end)
      |> Map.new()

    socket
    |> assign(:number_of_trivias, Enum.count(childs))
    |> assign(:available_trivias, available_trivias)
    |> assign(:in_game, false)
  end
end
