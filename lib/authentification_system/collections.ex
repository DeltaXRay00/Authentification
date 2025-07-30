defmodule AuthentificationSystem.Collections do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query, warn: false
  alias AuthentificationSystem.Repo

  alias AuthentificationSystem.Collections.{Game, Book}

  # Game functions

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Returns a paginated list of games with optional filtering.

  ## Examples

      iex> list_games_paginated(1, 10, %{search: "zelda", genre: "action"})
      %{entries: [%Game{}, ...], page_number: 1, page_size: 10, total_entries: 50, total_pages: 5}

  """
  def list_games_paginated(page \\ 1, page_size \\ 10, filters \\ %{}) do
    offset = (page - 1) * page_size

    query = build_games_query(filters)

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_entries / page_size)

    entries =
      query
      |> order_by([g], g.inserted_at)
      |> limit(^page_size)
      |> offset(^offset)
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp build_games_query(filters) do
    Game
    |> filter_by_search(filters["search"])
    |> filter_by_genre(filters["genre"])
    |> filter_by_company(filters["company"])
    |> filter_by_year(filters["year"])
  end

  defp filter_by_search(query, nil), do: query
  defp filter_by_search(query, search) when is_binary(search) and search != "" do
    search_term = "%#{search}%"
    query
    |> where([g], ilike(g.title, ^search_term) or ilike(g.company, ^search_term))
  end
  defp filter_by_search(query, _), do: query

  defp filter_by_genre(query, nil), do: query
  defp filter_by_genre(query, genre) when is_binary(genre) and genre != "" do
    query |> where([g], g.genre == ^genre)
  end
  defp filter_by_genre(query, _), do: query

  defp filter_by_company(query, nil), do: query
  defp filter_by_company(query, company) when is_binary(company) and company != "" do
    query |> where([g], g.company == ^company)
  end
  defp filter_by_company(query, _), do: query

  defp filter_by_year(query, nil), do: query
  defp filter_by_year(query, year) when is_integer(year) do
    query |> where([g], g.released_year == ^year)
  end
  defp filter_by_year(query, _), do: query

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  @doc """
  Returns list of unique genres for games.
  """
  def list_game_genres do
    Game
    |> distinct([g], g.genre)
    |> select([g], g.genre)
    |> Repo.all()
  end

  @doc """
  Returns list of unique companies for games.
  """
  def list_game_companies do
    Game
    |> distinct([g], g.company)
    |> select([g], g.company)
    |> Repo.all()
  end

  @doc """
  Returns list of unique years for games.
  """
  def list_game_years do
    Game
    |> distinct([g], g.released_year)
    |> select([g], g.released_year)
    |> order_by([g], g.released_year)
    |> Repo.all()
  end

  # Book functions

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Returns a paginated list of books with optional filtering.

  ## Examples

      iex> list_books_paginated(1, 10, %{search: "gatsby", genre: "fiction"})
      %{entries: [%Book{}, ...], page_number: 1, page_size: 10, total_entries: 50, total_pages: 5}

  """
  def list_books_paginated(page \\ 1, page_size \\ 10, filters \\ %{}) do
    offset = (page - 1) * page_size

    query = build_books_query(filters)

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_entries / page_size)

    entries =
      query
      |> order_by([b], b.inserted_at)
      |> limit(^page_size)
      |> offset(^offset)
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp build_books_query(filters) do
    Book
    |> filter_book_by_search(filters["search"])
    |> filter_book_by_genre(filters["genre"])
    |> filter_book_by_author(filters["author"])
    |> filter_book_by_year(filters["year"])
  end

  defp filter_book_by_search(query, nil), do: query
  defp filter_book_by_search(query, search) when is_binary(search) and search != "" do
    search_term = "%#{search}%"
    query
    |> where([b], ilike(b.title, ^search_term) or ilike(b.author, ^search_term))
  end
  defp filter_book_by_search(query, _), do: query

  defp filter_book_by_genre(query, nil), do: query
  defp filter_book_by_genre(query, genre) when is_binary(genre) and genre != "" do
    query |> where([b], b.genre == ^genre)
  end
  defp filter_book_by_genre(query, _), do: query

  defp filter_book_by_author(query, nil), do: query
  defp filter_book_by_author(query, author) when is_binary(author) and author != "" do
    query |> where([b], b.author == ^author)
  end
  defp filter_book_by_author(query, _), do: query

  defp filter_book_by_year(query, nil), do: query
  defp filter_book_by_year(query, year) when is_integer(year) do
    query |> where([b], b.published_year == ^year)
  end
  defp filter_book_by_year(query, _), do: query

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Returns list of unique genres for books.
  """
  def list_book_genres do
    Book
    |> distinct([b], b.genre)
    |> select([b], b.genre)
    |> Repo.all()
  end

  @doc """
  Returns list of unique authors for books.
  """
  def list_book_authors do
    Book
    |> distinct([b], b.author)
    |> select([b], b.author)
    |> Repo.all()
  end

  @doc """
  Returns list of unique years for books.
  """
  def list_book_years do
    Book
    |> distinct([b], b.published_year)
    |> select([b], b.published_year)
    |> order_by([b], b.published_year)
    |> Repo.all()
  end
end
