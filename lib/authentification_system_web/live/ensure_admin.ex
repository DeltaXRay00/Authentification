defmodule AuthentificationSystemWeb.EnsureAdmin do
  import Phoenix.Component, only: [assign: 3]

  def on_mount(:default, _params, session, socket) do
    user =
      case session do
        %{"user_token" => token} -> AuthentificationSystem.Accounts.get_user_by_session_token(token)
        _ -> nil
      end

    if user && user.role == "admin" do
      {:cont, assign(socket, :current_user, user)}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/")}
    end
  end
end
