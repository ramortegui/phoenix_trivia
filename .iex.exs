alias Trivia.Game
alias Trivia.GameServer
alias Trivia.Player
alias Trivia.Question

player_ruben = %Player{name: "Ruben"}
player_deisy = %Player{name: "Deisy"}
player_sofia = %Player{name: "Sofia"}
player_samuel = %Player{name: "Samuel"}

question_1 =
  Question.new(%{
    text: "Which franchise does the creature &quot;Slowpoke&quot; originate from?",
    options: ["Dragon Ball", "Sonic The Hedgehog", "Yugioh"],
    answer: "Pokemon"
  })

question_2 =
  Question.new(%{
    text:
      "How many Star Spirits do you rescue in the Nintendo 64 video game &quot;Paper Mario&quot;?",
    options: ["5", "10", "12"],
    answer: "7"
  })

game = Game.new(%{name: "game1", player: player_ruben})
# game = Game.add_question(game, question_1)
# game = Game.add_question(game, question_2)

{:ok, game_pid} = GameServer.start_link(game)

# GameServer.start_game(game_pid)
# GameServer.add_player(game_pid, player_deisy)
# GameServer.add_player(game_pid, player_sofia)
# GameServer.add_player(game_pid, player_samuel)

start_servers = fn quantity ->
  Enum.each(1..quantity, fn _iterator ->
    {:ok, pid} = Trivia.DynamicSupervisor.start_child(game)
    GameServer.start_game(pid)
  end)
end
