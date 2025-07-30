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
        released_year: 2017,
        genre: "Action-Adventure",
        platform: "Nintendo Switch"
      },
      %{
        title: "Red Dead Redemption 2",
        company: "Rockstar Games",
        released_year: 2018,
        genre: "Action-Adventure",
        platform: "PlayStation 4, Xbox One, PC"
      },
      %{
        title: "Cyberpunk 2077",
        company: "CD Projekt",
        released_year: 2020,
        genre: "RPG",
        platform: "PlayStation 4, Xbox One, PC"
      },
      %{
        title: "God of War",
        company: "Santa Monica Studio",
        released_year: 2018,
        genre: "Action-Adventure",
        platform: "PlayStation 4"
      },
      %{
        title: "The Witcher 3: Wild Hunt",
        company: "CD Projekt",
        released_year: 2015,
        genre: "RPG",
        platform: "PlayStation 4, Xbox One, PC"
      },
      %{
        title: "Spider-Man",
        company: "Insomniac Games",
        released_year: 2018,
        genre: "Action-Adventure",
        platform: "PlayStation 4"
      },
      %{
        title: "Horizon Zero Dawn",
        company: "Guerrilla Games",
        released_year: 2017,
        genre: "Action-RPG",
        platform: "PlayStation 4"
      },
      %{
        title: "Uncharted 4: A Thief's End",
        company: "Naughty Dog",
        released_year: 2016,
        genre: "Action-Adventure",
        platform: "PlayStation 4"
      },
      %{
        title: "Assassin's Creed Valhalla",
        company: "Ubisoft",
        released_year: 2020,
        genre: "Action-RPG",
        platform: "PlayStation 4, Xbox One, PC"
      },
      %{
        title: "Final Fantasy VII Remake",
        company: "Square Enix",
        released_year: 2020,
        genre: "RPG",
        platform: "PlayStation 4"
      },
      %{
        title: "Death Stranding",
        company: "Kojima Productions",
        released_year: 2019,
        genre: "Action",
        platform: "PlayStation 4"
      },
      %{
        title: "Resident Evil 2 Remake",
        company: "Capcom",
        released_year: 2019,
        genre: "Survival Horror",
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
      },
      %{
        title: "Pride and Prejudice",
        author: "Jane Austen",
        published_year: 1813,
        genre: "Romance"
      },
      %{
        title: "The Catcher in the Rye",
        author: "J.D. Salinger",
        published_year: 1951,
        genre: "Coming-of-age"
      },
      %{
        title: "Lord of the Flies",
        author: "William Golding",
        published_year: 1954,
        genre: "Allegory"
      },
      %{
        title: "Animal Farm",
        author: "George Orwell",
        published_year: 1945,
        genre: "Allegory"
      },
      %{
        title: "The Hobbit",
        author: "J.R.R. Tolkien",
        published_year: 1937,
        genre: "Fantasy"
      },
      %{
        title: "The Lord of the Rings",
        author: "J.R.R. Tolkien",
        published_year: 1954,
        genre: "Fantasy"
      },
      %{
        title: "Brave New World",
        author: "Aldous Huxley",
        published_year: 1932,
        genre: "Dystopian Fiction"
      },
      %{
        title: "Fahrenheit 451",
        author: "Ray Bradbury",
        published_year: 1953,
        genre: "Dystopian Fiction"
      },
      %{
        title: "The Alchemist",
        author: "Paulo Coelho",
        published_year: 1988,
        genre: "Fiction"
      }
    ]

    Enum.each(books, fn book_attrs ->
      Repo.insert!(%Book{} |> Book.changeset(book_attrs))
    end)

    IO.inspect("Books seeded successfully")
  _existing_books ->
    IO.inspect("Books already exist")
end
