defmodule Trivia.Game do
  defstruct name: '',
            current_question: nil,
            questions: [],
            players: [],
            status: '',
            winners: []

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.Question

  def new(%{name: name, player: %Player{} = player}) do
    %Game{name: name, status: "waiting"}
    |> add_player(player)
  end

  def add_player(%Game{players: players} = game, %Player{} = player) do
    %Game{game | players: [player | players]}
  end

  def add_question(%Game{questions: questions} = game, %Question{} = question) do
    %Game{game | questions: [question | questions]}
  end

  def change_status(
        %Game{status: status, players: players, questions: [question | questions]} = game
      )
      when status == "waiting" do
    players = Enum.map(players, &%Player{&1 | waiting_response: true})

    %Game{
      game
      | status: "playing",
        players: players,
        current_question: question,
        questions: questions
    }
  end

  def change_status(%Game{status: status, questions: questions} = game)
      when status == "playing" and questions == [] do
    game = add_winners(game)
    %Game{game | current_question: nil, status: "finished"}
  end

  def change_status(%Game{status: status} = game)
      when status == "playing",
      do: game

  def change_question(%Game{status: status, questions: [first | rest], players: players} = game)
      when status == "playing" do
    players = Enum.map(players, &%Player{&1 | waiting_response: true})
    %Game{game | current_question: first, questions: rest, players: players}
  end

  def change_question(%Game{} = game) do
    change_status(%Game{game | current_question: nil})
  end

  def check_answer(
        %Game{current_question: current_question} = game,
        %Player{name: player_name, waiting_response: true},
        answer
      ) do
    if Question.valid_answer?(current_question, answer) do
      add_point_to_player(game, player_name)
    else
      advance_question_for_user(game, player_name)
    end
  end

  def check_answer(%Game{} = game, _player, _answer), do: game

  def add_point_to_player(%Game{players: players} = game, player_name) do
    players =
      Enum.map(players, fn player ->
        if player.name == player_name and player.waiting_response do
          %Player{player | points: player.points + 1, waiting_response: false}
        else
          player
        end
      end)

    %Game{game | players: players}
  end

  def advance_question_for_user(%Game{players: players} = game, player_name) do
    players =
      Enum.map(players, fn player ->
        if player.name == player_name do
          %Player{player | waiting_response: false}
        else
          player
        end
      end)

    %Game{game | players: players}
  end

  def add_winners(%Game{players: players} = game) do
    max_points = Enum.max_by(players, & &1.points)
    winners = Enum.filter(players, &(&1.points == max_points.points))
    %Game{game | winners: winners}
  end
end
