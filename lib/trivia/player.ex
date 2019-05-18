defmodule Trivia.Player do
  defstruct name: '', points: 0
  alias Trivia.Player

  def new(name) do
    %Player{name: name}
  end
end
