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
alias AuthentificationSystem.Collections.{Game, Book}
alias AuthentificationSystem.Repo

# Create admin user if it doesn't exist
hashed_password = Pbkdf2.hash_pwd_salt("supersecret")

case Repo.get_by(User, email: "admin@site.com") do
  nil ->
    admin_user = Repo.insert!(%User{
      email: "admin@site.com",
      hashed_password: hashed_password,
      role: "admin"
    })
    IO.inspect(admin_user, label: "Admin user created")
  _existing_user ->
    IO.inspect("Admin user already exists")
end

# Seed Games (only if no games exist)
case Repo.aggregate(Game, :count, :id) do
  0 ->
    games = [
      %{
        title: "The Legend of Zelda: Breath of the Wild",
        company: "Nintendo",
        release_date: ~D[2017-03-03],
        genre: "Action-Adventure",
        platform: "Nintendo Switch"
      },
      %{
        title: "Red Dead Redemption 2",
        company: "Rockstar Games",
        release_date: ~D[2018-10-26],
        genre: "Action-Adventure",
        platform: "PlayStation 4, Xbox One, PC"
      },
      %{
        title: "Cyberpunk 2077",
        company: "CD Projekt",
        release_date: ~D[2020-12-10],
        genre: "RPG",
        platform: "PlayStation 4, Xbox One, PC"
      }
    ]

    Enum.each(games, fn game_attrs ->
      Repo.insert!(%Game{} |> Game.changeset(game_attrs))
    end)

    IO.inspect("Games seeded successfully")
  _existing_games ->
    IO.inspect("Games already exist")
end

# Seed Books (only if no books exist)
case Repo.aggregate(Book, :count, :id) do
  0 ->
    books = [
      %{
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        published_year: 1925,
        genre: "Classic Fiction"
      },
      %{
        title: "To Kill a Mockingbird",
        author: "Harper Lee",
        published_year: 1960,
        genre: "Classic Fiction"
      },
      %{
        title: "1984",
        author: "George Orwell",
        published_year: 1949,
        genre: "Dystopian Fiction"
      }
    ]

    Enum.each(books, fn book_attrs ->
      Repo.insert!(%Book{} |> Book.changeset(book_attrs))
    end)

    IO.inspect("Books seeded successfully")
  _existing_books ->
    IO.inspect("Books already exist")
end
