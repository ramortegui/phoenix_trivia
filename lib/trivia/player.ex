defmodule Trivia.Player do
  @moduledoc """
  Module used to define a player for a trivia
  """
  defstruct name: "", points: 0, waiting_response: false

  @doc """
  Returns a `Trivia.Player` struct with the name populated.

  ## Examples:

      iex> Trivia.Player.new("Ruben")
      %Trivia.Player{name: "Ruben", points: 0, waiting_response: false}

  """
  def new(name) when is_binary(name) do
    %__MODULE__{name: name}
  end
end
