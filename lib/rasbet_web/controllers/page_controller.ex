defmodule RasbetWeb.PageController do
  use RasbetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
