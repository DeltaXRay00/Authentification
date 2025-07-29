defmodule AuthentificationSystemWeb.AdminBooksLive do
  use AuthentificationSystemWeb, :live_view

  alias AuthentificationSystem.Collections

  def mount(_params, _session, socket) do
    books = Collections.list_books()
    {:ok, assign(socket, books: books, show_add_form: false)}
  end

  def handle_event("toggle-add-form", _params, socket) do
    {:noreply, assign(socket, show_add_form: !socket.assigns.show_add_form)}
  end

  def handle_event("add-book", %{"book" => book_params}, socket) do
    case Collections.create_book(book_params) do
      {:ok, _book} ->
        books = Collections.list_books()
        {:noreply, assign(socket, books: books, show_add_form: false)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-book", %{"id" => id}, socket) do
    book = Collections.get_book!(id)
    {:ok, _} = Collections.delete_book(book)
    books = Collections.list_books()
    {:noreply, assign(socket, books: books)}
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
                  min="1000"
                  max="2024"
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
              <%= for book <- @books do %>
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
                    <button
                      phx-click="delete-book"
                      phx-value-id={book.id}
                      data-confirm="Are you sure you want to delete this book?"
                      class="text-red-600 hover:text-red-900"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
