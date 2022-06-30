defmodule HephaestusWeb.PageController do
  use HephaestusWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
