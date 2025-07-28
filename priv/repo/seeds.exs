# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AuthentificationSystem.Repo.insert!(%AuthentificationSystem.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias AuthentificationSystem.Accounts.User
alias AuthentificationSystem.Repo

hashed_password = Pbkdf2.hash_pwd_salt("supersecret")

Repo.insert!(%User{
  email: "admin@site.com",
  hashed_password: hashed_password,
  role: "admin"
})

IO.inspect(result, label: "Admin registration result")
