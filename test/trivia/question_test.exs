defmodule Trivia.QuestionTest do
  use ExUnit.Case, async: true

  alias Trivia.Question

  test "new question includes the answer in as an option" do
    text = "Which franchise does the creature &quot;Slowpoke&quot; originate from?"
    options = ["Dragon Ball", "Sonic The Hedgehog", "Yugioh"]
    answer = "Pokemon"

    question =
      Question.new(%{
        text: text,
        options: options,
        answer: answer
      })

    assert Enum.any?(question.options, &(&1 == answer))
  end
end
