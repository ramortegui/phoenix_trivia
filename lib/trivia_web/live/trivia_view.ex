defmodule Trivia.TriviaView do
  use Phoenix.LiveView

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.GameServer

  def render(assigns) do
    ~L"""
    <div class="section">
    <h1>Name: <%= @player_name %></h1>
      <%= if @in_game do %>
        <div>
        <div><h2>Status: <%= @trivia.status %></h2></div>

        <%= if (@trivia_status == "playing") do %>
          <ul>
            <%= for player <- @trivia.players do %>
              <li><%= player.name %> - points: <%= player.points %></li>
            <% end %>
          </ul>
        <% end %>
        <%= if (@trivia_status == "finished") do %>
          <h2>Winners</h2>
          <ul>
            <%= for winner <- @trivia.winners do %>
              <li><%= winner.name %></li>
            <% end %>
          </ul>
        <% end %>
        <%= if @trivia.current_question do %>
          <div>
            <h3>Question <%= @trivia.used_questions+1 %>/<%= @trivia.total_questions %></h3>
          </div>
          <div><progress id="progress-bar" class="progress is-info"  value="<%= @trivia.counter %>" max="<%= @trivia.counter_total %>"></progress></div>
          <div>
            <p><%= Phoenix.HTML.raw @trivia.current_question.text %></p>
          </div>
          <div>
          <%= for option <- @trivia.current_question.options do %>
          <div class="column">
          <button class="button is-info" phx-click="submit_answer" phx-value="<%= option %>"><%= Phoenix.HTML.raw option %></button>
          </div>
          <% end %>
        </div>
        <% else %>
          <div>
          <progress id="progress-bar" class="progress is-info is-large" value="<%= @trivia.counter %>" max="<%= @trivia.counter_total %>"></progress>
          </div>
        <% end %>
        </div>
      <% else %>
        <div>
          <button class="button is-info" phx-click="create_trivia" phx-value="<%= @player_name %>">Create + Join</button>
          Number of trivias: <%= @number_of_trivias %>
          <%= for trivia <- @available_trivias do %>
            <button class="button is-info" phx-click="join_trivia" phx-value=<%= elem(trivia,0) %>>Join</button>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    if(connected?(socket), do: :timer.send_interval(10, self(), :tick))

    player_name = "player_#{:rand.uniform(10000000)}"

    socket =
      socket
      |> assign(
        in_game: false,
        trivia: nil,
        process: nil,
        trivia_status: nil,
        number_of_trivias: 0,
        available_trivias: [],
        player_name:  player_name
      )

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, update_game_info(socket)}
  end

  def update_game_info(socket) do
    game_pid = socket.assigns.process
    game = socket.assigns.trivia

    if game == nil do
      trivias(socket)
    else
      game = GameServer.game(game_pid)
      if game.status == "finished" and game.counter == 0 do
        clean_game(socket)
      else
        socket
        |> assign(:trivia, game)
        |> assign(:trivia_status, game.status)
      end
    end
  end

  def handle_event("create_trivia", value, socket) do
    player_name = socket.assigns.player_name
    game = Game.new(%{name: value, player: Player.new(player_name)})
    {:ok, game_pid} = Trivia.DynamicSupervisor.start_child(game)
    GameServer.start_game(game_pid)
    {:noreply, assign_game(socket, game_pid)}
  end

  def handle_event("join_trivia", value, socket) do
    game_pid = Map.get(socket.assigns.available_trivias, String.to_integer(value))
    player_name = socket.assigns.player_name
    GameServer.add_player(game_pid, Player.new(player_name))
    {:noreply, assign_game(socket, game_pid)}
  end

  def handle_event("submit_answer", value, socket) do
    game_pid = socket.assigns.process
    player_name = socket.assigns.player_name

    socket =
      if is_pid(game_pid) and Process.alive?(game_pid) do
        socket
        |> update(:trivia, fn _trivia ->
          GameServer.submit_answer(game_pid, player_name, value)
          GameServer.game(game_pid)
        end)
      else
        socket
        |> assign(:in_game, false)
      end

    {:noreply, socket}
  end

  def handle_event("return-main", _value, socket) do
    socket = socket
             |> assign(:in_game, false)
             |> trivias()
    {:noreply, socket}
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
