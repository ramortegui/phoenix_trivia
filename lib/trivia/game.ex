defmodule Trivia.Game do
  defstruct name: '',
            current_question: nil,
            questions: [],
            players: [],
            status: ''

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.Question

  def new(%{name: name, player: %Player{} = player}) do
    %Game{name: name, status: 'waiting'}
    |> add_player(player)
  end

  def add_player(%Game{players: players} = game, %Player{} = player) do
    %Game{game | players: [player | players]}
  end

  def add_question(%Game{questions: questions}, %Question{} = question) do
    %Game{game | questions: [question | questions]}
  end

  def change_status(%Game{status: status} = game) when status == "waiting",
    do: %Game{game | status: "playing"}

  def change_status(%Game{status: status, questions: questions} = game)
      when status == "playing" and questions == [],
      do: %Game{game | status: "finished"}

  def change_status(%Game{status: status} = game)
      when status == "playing",
      do: game

  def change_status(%Game{} = game),
    do: %Game{game | status: "finished"}

  def change_question(%Game{status: status, questions: [first | rest]} = game)
      when status == "playing" do
    %Game{game | current_question: first, questions: rest}
  end

  def change_question(game) do
    change_status(game)
  end

  def check_answer(
        %Game{current_question: current_question} = game,
        %Player{name: player_name},
        answer
      ) do
    if Question.valid_answer?(current_question, answer) do
      add_point_to_player(game, player_name)
    else
      game
    end
  end

  def add_point_to_player(%Game{players: players} = game, player_name) do
    players =
      Enum.map(players, fn player ->
        if player.name == player_name do
          %Player{player | points: player.points + 1}
        else
          player
        end
      end)

    %Game{game | players: players}
  end
end
