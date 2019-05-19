defmodule Trivia.TriviaView do
  use Phoenix.LiveView

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.GameServer

  def render(assigns) do
    ~L"""
    <div class="">
    <%= if @in_game != nil do %>
      <%= @trivia.status %>
      <%= else %>
      <div>
        <button phx-click="create_trivia" phx-value="Ruben">Create + Join</button>
        Number of trivias: <%= @number_of_trivias %>
    </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    nerds = DynamicSupervisor.count_children(Trivia.DynamicSupervisor)
    socket = assign(socket, counter: 0, number_of_trivias: nerds[:active],
    in_game: nil, trivia: nil)
    {:ok, socket}
  end

  def handle_event("create_trivia", value, socket) do
    game = Game.new(%{name: "game1", player: Player.new(name: value)})
    {:ok, game_pid} = Trivia.DynamicSupervisor.start_child(game)
    nerds = DynamicSupervisor.count_children(Trivia.DynamicSupervisor)
    socket =  assign(socket, :number_of_trivias, nerds[:active])
    socket =  assign(socket, :in_game, game_pid)
    socket =  assign(socket, :trivia, GameServer.game(game_pid))
    GameServer.start_game(game_pid)
    {:noreply, socket}
  end
end
