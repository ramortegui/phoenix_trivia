defmodule Trivia.Player do
  @moduledoc """
  Module used to define a player for a trivia
  """
  defstruct name: '', points: 0, waiting_response: false
  alias Trivia.Player

  def new(name) do
    %Player{name: name}
  end
end
