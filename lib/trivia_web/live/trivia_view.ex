defmodule Trivia.TriviaView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <div>
          <button phx-click="add_counter">+</button>
          <button phx-click="sub_counter">-</button>
        </div>
        Status: <%= @counter %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, counter: 0)}
  end

  def handle_event("add_counter", _value, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter + 1)}
  end

  def handle_event("sub_counter", _value, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter - 1)}
  end
end
