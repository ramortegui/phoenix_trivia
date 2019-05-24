defmodule TriviaWeb.PageControllerTest do
  use TriviaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "https://github.com/ramortegui/phoenix_trivia"
  end
end
