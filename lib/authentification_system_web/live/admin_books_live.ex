defmodule AuthentificationSystemWeb.AdminBooksLive do
  use AuthentificationSystemWeb, :live_view

  alias AuthentificationSystem.Collections

  def mount(%{"page" => page} = params, _session, socket) do
    page = String.to_integer(page)
    filters = extract_filters(params)
    books_page = Collections.list_books_paginated(page, 10, get_db_filters(filters))
    filter_options = get_filter_options()
    {:ok, assign(socket, books_page: books_page, show_add_form: false, editing_book: nil, filters: filters, filter_options: filter_options)}
  end

  def mount(params, _session, socket) do
    filters = extract_filters(params)
    books_page = Collections.list_books_paginated(1, 10, get_db_filters(filters))
    filter_options = get_filter_options()
    {:ok, assign(socket, books_page: books_page, show_add_form: false, editing_book: nil, filters: filters, filter_options: filter_options)}
  end

  def handle_event("toggle-add-form", _params, socket) do
    {:noreply, assign(socket, show_add_form: !socket.assigns.show_add_form, editing_book: nil)}
  end

    def handle_event("filter", %{"filters" => filters}, socket) do
    # Parse the year parameter if it exists
    filters_with_parsed_year = Map.update(filters, "year", nil, &parse_year/1)
    # Navigate to URL with filter parameters
    {:noreply, push_navigate(socket, to: build_filter_url(1, filters_with_parsed_year))}
  end





    def handle_event("clear-filters", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/collection/books")}
  end

  def handle_event("edit-book", %{"id" => id}, socket) do
    book = Collections.get_book!(id)
    {:noreply, assign(socket, editing_book: book, show_add_form: false)}
  end

  def handle_event("cancel-edit", _params, socket) do
    {:noreply, assign(socket, editing_book: nil)}
  end

  def handle_event("update-book", %{"book" => book_params, "_id" => id}, socket) do
    book = Collections.get_book!(id)

    case Collections.update_book(book, book_params) do
      {:ok, _updated_book} ->
        books_page = Collections.list_books_paginated(socket.assigns.books_page.page_number, 10, get_db_filters(socket.assigns.filters))
        {:noreply, assign(socket, books_page: books_page, editing_book: nil)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("add-book", %{"book" => book_params}, socket) do
    case Collections.create_book(book_params) do
      {:ok, _book} ->
        books_page = Collections.list_books_paginated(socket.assigns.books_page.page_number, 10, get_db_filters(socket.assigns.filters))
        {:noreply, assign(socket, books_page: books_page, show_add_form: false)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-book", %{"id" => id}, socket) do
    book = Collections.get_book!(id)
    {:ok, _} = Collections.delete_book(book)
    books_page = Collections.list_books_paginated(socket.assigns.books_page.page_number, 10, get_db_filters(socket.assigns.filters))
    {:noreply, assign(socket, books_page: books_page)}
  end

  defp extract_filters(params) do
    %{
      "search" => params["search"] || "",
      "genre" => params["genre"] || "",
      "author" => params["author"] || "",
      "year" => params["year"] || ""  # Keep as string for form display
    }
  end

  defp parse_year(nil), do: nil
  defp parse_year(""), do: nil
  defp parse_year(year) when is_binary(year) do
    case Integer.parse(year) do
      {year_int, _} -> year_int
      :error -> nil
    end
  end
  defp parse_year(year) when is_integer(year), do: year
  defp parse_year(_), do: nil

  defp get_filter_options do
    %{
      genres: Collections.list_book_genres(),
      authors: Collections.list_book_authors(),
      years: Collections.list_book_years()
    }
  end

  defp build_filter_url(page, filters) do
    query_params = filters
    |> Enum.reject(fn {_key, value} -> is_nil(value) || value == "" end)
    |> Enum.map(fn {key, value} ->
      # Keep year as string for URL, but ensure it's properly formatted
      if key == "year" and is_integer(value) do
        "#{key}=#{value}"
      else
        "#{key}=#{URI.encode_www_form(value)}"
      end
    end)
    |> Enum.join("&")

    base_url = ~p"/admin/collection/books"

    if query_params != "" do
      "#{base_url}?page=#{page}&#{query_params}"
    else
      "#{base_url}?page=#{page}"
    end
  end

  defp build_pagination_url(page, filters) do
    build_filter_url(page, filters)
  end

  # Helper function to get filters for database queries
  defp get_db_filters(filters) do
    %{
      "search" => filters["search"],
      "genre" => filters["genre"],
      "author" => filters["author"],
      "year" => parse_year(filters["year"])  # Parse as integer for DB
    }
  end


  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Books Collection</h1>
          <p class="text-gray-600">Manage your book collection</p>
        </div>
        <button
          phx-click="toggle-add-form"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Add Book
        </button>
      </div>

      <!-- Filters -->
      <div class="bg-white shadow rounded-lg p-6 border border-gray-200">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Filters</h3>
        <form phx-change="filter" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <label for="search" class="block text-sm font-medium text-gray-700">Search</label>
              <input
                type="text"
                name="filters[search]"
                id="search"
                value={@filters["search"] || ""}
                placeholder="Search books..."
                phx-debounce="300"
                class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div>
              <label for="genre" class="block text-sm font-medium text-gray-700">Genre</label>
              <select
                name="filters[genre]"
                id="genre"
                class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">All Genres</option>
                <%= for genre <- @filter_options.genres do %>
                  <option value={genre} selected={@filters["genre"] == genre}>
                    <%= genre %>
                  </option>
                <% end %>
              </select>
            </div>
            <div>
              <label for="author" class="block text-sm font-medium text-gray-700">Author</label>
              <select
                name="filters[author]"
                id="author"
                class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">All Authors</option>
                <%= for author <- @filter_options.authors do %>
                  <option value={author} selected={@filters["author"] == author}>
                    <%= author %>
                  </option>
                <% end %>
              </select>
            </div>
            <div>
              <label for="year" class="block text-sm font-medium text-gray-700">Year</label>
              <select
                name="filters[year]"
                id="year"
                class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">All Years</option>
                <%= for year <- @filter_options.years do %>
                  <option value={year} selected={@filters["year"] == to_string(year)}>
                    <%= year %>
                  </option>
                <% end %>
              </select>
            </div>
          </div>
          <div class="flex justify-end">
            <button
              type="button"
              phx-click="clear-filters"
              class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Clear Filters
            </button>
          </div>
        </form>
      </div>

      <!-- Add Book Form -->
      <%= if @show_add_form do %>
        <div class="bg-white shadow rounded-lg p-6 border border-gray-200">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Add New Book</h3>
          <form phx-submit="add-book" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="title" class="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  name="book[title]"
                  id="title"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="author" class="block text-sm font-medium text-gray-700">Author</label>
                <input
                  type="text"
                  name="book[author]"
                  id="author"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="published_year" class="block text-sm font-medium text-gray-700">Published Year</label>
                <input
                  type="number"
                  name="book[published_year]"
                  id="published_year"
                  min="1900"
                  max="2030"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="genre" class="block text-sm font-medium text-gray-700">Genre</label>
                <input
                  type="text"
                  name="book[genre]"
                  id="genre"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
            <div class="flex justify-end space-x-3">
              <button
                type="button"
                phx-click="toggle-add-form"
                class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Add Book
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <!-- Edit Book Form -->
      <%= if @editing_book do %>
        <div class="bg-white shadow rounded-lg p-6 border border-gray-200">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Edit Book: <%= @editing_book.title %></h3>
          <form phx-submit="update-book" class="space-y-4">
            <input type="hidden" name="_id" value={@editing_book.id} />
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="edit_title" class="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  name="book[title]"
                  id="edit_title"
                  value={@editing_book.title}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="edit_author" class="block text-sm font-medium text-gray-700">Author</label>
                <input
                  type="text"
                  name="book[author]"
                  id="edit_author"
                  value={@editing_book.author}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="edit_published_year" class="block text-sm font-medium text-gray-700">Published Year</label>
                <input
                  type="number"
                  name="book[published_year]"
                  id="edit_published_year"
                  value={@editing_book.published_year}
                  min="1900"
                  max="2030"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="edit_genre" class="block text-sm font-medium text-gray-700">Genre</label>
                <input
                  type="text"
                  name="book[genre]"
                  id="edit_genre"
                  value={@editing_book.genre}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
            <div class="flex justify-end space-x-3">
              <button
                type="button"
                phx-click="cancel-edit"
                class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                Update Book
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <!-- Books Table -->
      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="px-4 py-5 sm:px-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">Books List</h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500">All books in your collection</p>
        </div>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Author</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Published Year</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Genre</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for book <- @books_page.entries do %>
                <tr class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= book.title %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= book.author %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= book.published_year %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= book.genre %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div class="flex space-x-2">
                      <button
                        phx-click="edit-book"
                        phx-value-id={book.id}
                        class="text-blue-600 hover:text-blue-900"
                        title="Edit book"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                      <button
                        phx-click="delete-book"
                        phx-value-id={book.id}
                        data-confirm="Are you sure you want to delete this book?"
                        class="text-red-600 hover:text-red-900"
                        title="Delete book"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
          <div class="flex-1 flex justify-between sm:hidden">
                        <%= if @books_page.page_number > 1 do %>
              <.link
                navigate={build_pagination_url(@books_page.page_number - 1, @filters)}
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              >
                Previous
              </.link>
            <% else %>
              <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-300 bg-white cursor-not-allowed">
                Previous
              </span>
            <% end %>

            <%= if @books_page.page_number < @books_page.total_pages do %>
              <.link
                navigate={build_pagination_url(@books_page.page_number + 1, @filters)}
                class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              >
                Next
              </.link>
            <% else %>
              <span class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-300 bg-white cursor-not-allowed">
                Next
              </span>
            <% end %>
          </div>

          <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p class="text-sm text-gray-700">
                Showing <span class="font-medium"><%= (@books_page.page_number - 1) * @books_page.page_size + 1 %></span> to <span class="font-medium"><%= min(@books_page.page_number * @books_page.page_size, @books_page.total_entries) %></span> of <span class="font-medium"><%= @books_page.total_entries %></span> results
              </p>
            </div>
            <div>
              <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                                <%= if @books_page.page_number > 1 do %>
                  <.link
                    navigate={build_pagination_url(@books_page.page_number - 1, @filters)}
                    class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <span class="sr-only">Previous</span>
                    <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </.link>
                <% end %>

                <%= for page_num <- max(1, @books_page.page_number - 2)..min(@books_page.total_pages, @books_page.page_number + 2) do %>
                  <%= if page_num == @books_page.page_number do %>
                    <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-blue-50 text-sm font-medium text-blue-600">
                      <%= page_num %>
                    </span>
                  <% else %>
                    <.link
                      navigate={build_pagination_url(page_num, @filters)}
                      class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
                    >
                      <%= page_num %>
                    </.link>
                  <% end %>
                <% end %>

                <%= if @books_page.page_number < @books_page.total_pages do %>
                  <.link
                    navigate={build_pagination_url(@books_page.page_number + 1, @filters)}
                    class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <span class="sr-only">Next</span>
                    <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                    </svg>
                  </.link>
                <% end %>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
