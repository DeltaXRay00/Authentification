defmodule AuthentificationSystem.Repo do
  use Ecto.Repo,
    otp_app: :authentification_system,
    adapter: Ecto.Adapters.Postgres
end
