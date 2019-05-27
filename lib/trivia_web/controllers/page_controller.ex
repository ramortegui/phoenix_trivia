defmodule TriviaWeb.PageController do
  use TriviaWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, TriviaWeb.Live.TriviaView, session: %{})
  end
end
