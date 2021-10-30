defmodule CatbusDashboardWeb.PageController do
  use CatbusDashboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
