defmodule AuthentificationSystem.CollectionsTest do
  use AuthentificationSystem.DataCase

  alias AuthentificationSystem.Collections
  alias AuthentificationSystem.Collections.{Game, Book}

  describe "games pagination" do
    test "list_games_paginated/2 returns paginated results" do
      # Create test games
      games = for i <- 1..15 do
        %Game{
          title: "Test Game #{i}",
          company: "Test Company #{i}",
          released_year: 2020,
          genre: "Action",
          platform: "PC"
        }
      end

      Enum.each(games, &AuthentificationSystem.Repo.insert!/1)

      # Test first page
      result = Collections.list_games_paginated(1, 10)
      assert length(result.entries) == 10
      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries >= 15
      assert result.total_pages >= 2

      # Test second page
      result2 = Collections.list_games_paginated(2, 10)
      # The second page should have the remaining items (15 total - 10 from first page = 5)
      assert length(result2.entries) >= 5
      assert result2.page_number == 2
    end
  end

  describe "books pagination" do
    test "list_books_paginated/2 returns paginated results" do
      # Create test books
      books = for i <- 1..15 do
        %Book{
          title: "Test Book #{i}",
          author: "Test Author #{i}",
          published_year: 2020,
          genre: "Fiction"
        }
      end

      Enum.each(books, &AuthentificationSystem.Repo.insert!/1)

      # Test first page
      result = Collections.list_books_paginated(1, 10)
      assert length(result.entries) == 10
      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries >= 15
      assert result.total_pages >= 2

      # Test second page
      result2 = Collections.list_books_paginated(2, 10)
      # The second page should have the remaining items (15 total - 10 from first page = 5)
      assert length(result2.entries) >= 5
      assert result2.page_number == 2
    end
  end
end
