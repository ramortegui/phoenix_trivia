defmodule Trivia.QuestionTest do
  use ExUnit.Case, async: true

  alias Trivia.Question

  setup do
    text = "Which franchise does the creature &quot;Slowpoke&quot; originate from?"
    options = ["Dragon Ball", "Sonic The Hedgehog", "Yugioh"]
    answer = "Pokemon"

    question =
      Question.new(%{
        text: text,
        options: options,
        answer: answer
      })

    %{question: question}
  end

  test "new question includes the answer in as an option", context do
    question = context[:question]
    assert Enum.any?(question.options, &(&1 == question.answer))
  end

  test "valid_answer? returns a boolean to indicate if the guess is correct", context do
    question = context[:question]
    invalid_answer = "Dragon Ball"
    valid_answer = "Pokemon"

    assert Question.valid_answer?(question, invalid_answer) == false
    assert Question.valid_answer?(question, valid_answer) == true
  end
end
