defmodule AuthentificationSystemWeb.Admin.DashboardController do
  use AuthentificationSystemWeb, :controller

  plug :put_layout, html: {AuthentificationSystemWeb.Layouts, :admin}

  def index(conn, _params) do
    render(conn, :index)
  end
end
