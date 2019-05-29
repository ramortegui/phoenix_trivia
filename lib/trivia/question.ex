defmodule Trivia.Question do
  @moduledoc """
  Define question structure and validations.
  """
  defstruct text: "", options: [], answer: ''

  @doc """
  Returns a `Trivia.Question` Struct with shuffled options, the answer is included as part of the options.
  """
  def new(%{text: text, options: options, answer: answer}) do
    shuffled_options = Enum.shuffle([answer | options])
    %__MODULE__{text: text, options: shuffled_options, answer: answer}
  end

  @doc """
  Check the answer of a question
  """
  def valid_answer?(%__MODULE__{answer: answer}, guess) when answer == guess, do: true
  def valid_answer?(_question, _guess), do: false
end
