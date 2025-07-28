defmodule AuthentificationSystemWeb.AdminDashboardLive do
  use AuthentificationSystemWeb, :live_view

  on_mount AuthentificationSystemWeb.EnsureAdmin

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Dashboard")}
  end

  def render(assigns) do
    ~H"""
    <h1>Welcome, Admin!</h1>
    <p>This is the admin dashboard.</p>
    """
  end
end
