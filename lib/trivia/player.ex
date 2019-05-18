defmodule Trivia.Player do
  defstruct name: '', points: 0, waiting_response: false
  alias Trivia.Player

  def new(name) do
    %Player{name: name}
  end
end
