defmodule Trivia.Game do
  defstruct name: '',
            current_question: nil,
            questions: [],
            players: [],
            status: '',
            winners: [],
            counter: 0,
            total_questions: 0,
            used_questions: 0

  alias Trivia.Game
  alias Trivia.Player
  alias Trivia.Question

  @waiting_to_subscribe 10
  @waiting_to_question 5
  @open_trivia_url "https://opentdb.com/api.php?amount=10&type=multiple"

  def new(%{name: name, player: %Player{} = player}) do
    %Game{name: name, status: "waiting"}
    |> get_questions()
    |> add_player(player)
  end

  def start_game(%Game{} = game) do
    %Game{game | counter: @waiting_to_subscribe}
  end

  def add_player(%Game{players: players} = game, %Player{} = player) do
    %Game{game | players: [player | players]}
  end

  def get_questions(%Game{} = game) do
    request_questions()
    |> decode_questions
    |> parse_questions
    |> add_questions(game)
  end

  def request_questions do
    case HTTPoison.get!(@open_trivia_url) do
      %{body: body, status_code: 200} ->
        body

      %{status_bode: 404} ->
        nil
    end
  end

  def decode_questions(body) do
    case Jason.decode(body) do
      {:ok, %{"response_code" => 0, "results" => questions}} ->
        questions

      {:error, _reason} ->
        []
    end
  end

  def parse_questions(raw_questions_list) do
    Enum.map(raw_questions_list, fn question ->
      Question.new(%{
        text: question["question"],
        options: question["incorrect_answers"],
        answer: question["correct_answer"]
      })
    end)
  end

  def add_questions(questions, %Game{} = game) do
    Enum.reduce(questions, game, fn question, acc_game ->
      add_question(acc_game, question)
    end)
  end

  def add_question(
        %Game{questions: questions, total_questions: total_questions} = game,
        %Question{} = question
      ) do
    %Game{game | questions: [question | questions], total_questions: total_questions + 1}
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
        questions: questions,
        counter: @waiting_to_question
    }
  end

  def change_status(%Game{status: status} = game)
      when status == "finished" do
    game = add_winners(game)
    %Game{game | current_question: nil}
  end

  def change_status(%Game{status: status} = game)
      when status == "playing",
      do: game

  def change_question(
        %Game{
          status: status,
          questions: [first | rest],
          players: players,
          used_questions: used_questions
        } = game
      )
      when status == "playing" do
    players = Enum.map(players, &%Player{&1 | waiting_response: true})

    %Game{
      game
      | current_question: first,
        questions: rest,
        players: players,
        counter: @waiting_to_question,
        used_questions: used_questions + 1
    }
  end

  def change_question(%Game{status: status, questions: [], used_questions: used_questions} = game)
      when status == "playing" do
    change_status(%Game{
      game
      | current_question: nil,
        counter: 0,
        used_questions: used_questions + 1,
        status: "finished"
    })
  end

  def decrement_counter(%Game{counter: counter} = game) do
    %Game{game | counter: counter - 1}
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
