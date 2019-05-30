defmodule TriviaWeb.PageController do
  use TriviaWeb, :controller
  def index(conn, _params) do
    render(conn, "index.html")
    #   LiveView.Controller.live_render(conn, TriviaWeb.Live.TriviaView, session: %{})
  end
end
