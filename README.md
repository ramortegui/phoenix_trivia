# Trivia

Trivia is an experiment with Phoenix LiveView.

The process to build this app in summary was divided in 6 steps:

1- Modules to define the datastructure to play a trivia
   Trivia.Game
   Trivia.Player
   Trivia.Question 
2- A GenServer to maintain the state of the application
   Trivia.GameServer
3- A Dynamic Supervisor link the games
   Trivia.DynamicSupervisor
4- A live view definition integration and a definition of a template
   Trivia.TriviaView
5- Some refactoring (still far from what I want)
   TODO: "test everything!!!"
6- Add some styles 

The trivia is taking questions from (Trivia API)[https://opentdb.com/api_config.php].

It's deployed using (gigalixir)[https://www.gigalixir.com/] service and can be
found at: (https://idiotic-hearty-davidstiger.gigalixirapp.com/)[https://idiotic-hearty-davidstiger.gigalixirapp.com/]

The application is only using websockets, no session data.  So any refresh will
create a new user.

The application  was written only configuring and adding predefined javascript
libraries.  So basically no javascript code written by this programmer on this
reactive server render app. :)


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
