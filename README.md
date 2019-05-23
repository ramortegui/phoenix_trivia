# Trivia

Trivia is an experiment with Phoenix LiveView.

## Architecture

The process to build this app in summary was divided in 6 steps:

1. Modules to define the datastructure to play a trivia
   - Trivia.Game
   - Trivia.Player
   - Trivia.Question 
   
1. A GenServer to maintain the state of the application
   - Trivia.GameServer
   
1. A Dynamic Supervisor link the games
   - Trivia.DynamicSupervisor
1. A live view definition integration and a definition of a template
   - Trivia.TriviaView
1. Some refactoring (still far from what I want)

1. Add bulma css to style 

## TODO

"test everything!!!, improve UI, Refactor, etc.etc.  The main goal was to use live view, and it has been  accomplished"

## About the app

My game, my rules! :D.  It's a basic trivia, so don't expect far from asking some question and checking answers :)

Trivia is getting questions from [https://opentdb.com/api_config.php](Trivia API).

The application has been deployed using [https://www.gigalixir.com/](gigalixir) service and can be
found at: [https://idiotic-hearty-davidstiger.gigalixirapp.com/](https://idiotic-hearty-davidstiger.gigalixirapp.com/)

The application is using websockets so any new socket connection of refresh of the page will create a user.  Now, it's reactive, but I only use javascript to load a predefined libraries and config the app. :D


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
