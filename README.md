# Trivia

Trivia is an experiment with Phoenix LiveView.

[trivia screenshot](assets/static/images/phx-trivia.png)

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

## About the game

Trivia is getting 5 Computer/IT questions from [`Trivia API`](https://opentdb.com/api_config.php),
the players can join to other trivias on the waiting period.
On the botton you can see the positions.  The player(s) with the higher score
win the game.

## About the app


Trivia app is reactive, but I only use javascript to load a predefined libraries and config the app. :D.  [`https://github.com/phoenixframework/phoenix_live_view`](https://github.com/phoenixframework/phoenix_live_view) it's awesome!

The application has been deployed in [`gigalixir`](https://www.gigalixir.com/) and can be
found at: [`https://phx-trivia.gigalixirapp.com/`](https://phx-trivia.gigalixirapp.com/)

To start your Phoenix server locally:

  * Have elixir installed :)
  * Clone the repo with `git clone https://github.com/ramortegui/phoenix_trivia`
  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
