defmodule TriviaWeb.PageController do
  use TriviaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
