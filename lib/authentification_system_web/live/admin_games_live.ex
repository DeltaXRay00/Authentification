defmodule AuthentificationSystemWeb.AdminGamesLive do
  use AuthentificationSystemWeb, :live_view

  alias AuthentificationSystem.Collections

  def mount(%{"page" => page}, _session, socket) do
    page = String.to_integer(page)
    games_page = Collections.list_games_paginated(page, 10)
    {:ok, assign(socket, games_page: games_page, show_add_form: false, editing_game: nil)}
  end

  def mount(_params, _session, socket) do
    games_page = Collections.list_games_paginated(1, 10)
    {:ok, assign(socket, games_page: games_page, show_add_form: false, editing_game: nil)}
  end

  def handle_event("toggle-add-form", _params, socket) do
    {:noreply, assign(socket, show_add_form: !socket.assigns.show_add_form, editing_game: nil)}
  end

  def handle_event("edit-game", %{"id" => id}, socket) do
    game = Collections.get_game!(id)
    {:noreply, assign(socket, editing_game: game, show_add_form: false)}
  end

  def handle_event("cancel-edit", _params, socket) do
    {:noreply, assign(socket, editing_game: nil)}
  end

  def handle_event("update-game", %{"game" => game_params, "_id" => id}, socket) do
    game = Collections.get_game!(id)

    case Collections.update_game(game, game_params) do
      {:ok, _updated_game} ->
        games_page = Collections.list_games_paginated(socket.assigns.games_page.page_number, 10)
        {:noreply, assign(socket, games_page: games_page, editing_game: nil)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("add-game", %{"game" => game_params}, socket) do
    case Collections.create_game(game_params) do
      {:ok, _game} ->
        games_page = Collections.list_games_paginated(socket.assigns.games_page.page_number, 10)
        {:noreply, assign(socket, games_page: games_page, show_add_form: false)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-game", %{"id" => id}, socket) do
    game = Collections.get_game!(id)
    {:ok, _} = Collections.delete_game(game)
    games_page = Collections.list_games_paginated(socket.assigns.games_page.page_number, 10)
    {:noreply, assign(socket, games_page: games_page)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Games Collection</h1>
          <p class="text-gray-600">Manage your game collection</p>
        </div>
        <button
          phx-click="toggle-add-form"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Add Game
        </button>
      </div>

      <!-- Add Game Form -->
      <%= if @show_add_form do %>
        <div class="bg-white shadow rounded-lg p-6 border border-gray-200">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Add New Game</h3>
          <form phx-submit="add-game" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="title" class="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  name="game[title]"
                  id="title"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="company" class="block text-sm font-medium text-gray-700">Company</label>
                <input
                  type="text"
                  name="game[company]"
                  id="company"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="released_year" class="block text-sm font-medium text-gray-700">Released Year</label>
                <input
                  type="number"
                  name="game[released_year]"
                  id="released_year"
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
                  name="game[genre]"
                  id="genre"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="md:col-span-2">
                <label for="platform" class="block text-sm font-medium text-gray-700">Platform</label>
                <input
                  type="text"
                  name="game[platform]"
                  id="platform"
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
                Add Game
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <!-- Edit Game Form -->
      <%= if @editing_game do %>
        <div class="bg-white shadow rounded-lg p-6 border border-gray-200">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Edit Game: <%= @editing_game.title %></h3>
          <form phx-submit="update-game" class="space-y-4">
            <input type="hidden" name="_id" value={@editing_game.id} />
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="edit_title" class="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  name="game[title]"
                  id="edit_title"
                  value={@editing_game.title}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="edit_company" class="block text-sm font-medium text-gray-700">Company</label>
                <input
                  type="text"
                  name="game[company]"
                  id="edit_company"
                  value={@editing_game.company}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label for="edit_released_year" class="block text-sm font-medium text-gray-700">Released Year</label>
                <input
                  type="number"
                  name="game[released_year]"
                  id="edit_released_year"
                  value={@editing_game.released_year}
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
                  name="game[genre]"
                  id="edit_genre"
                  value={@editing_game.genre}
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="md:col-span-2">
                <label for="edit_platform" class="block text-sm font-medium text-gray-700">Platform</label>
                <input
                  type="text"
                  name="game[platform]"
                  id="edit_platform"
                  value={@editing_game.platform}
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
                Update Game
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <!-- Games Table -->
      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="px-4 py-5 sm:px-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">Games List</h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500">All games in your collection</p>
        </div>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Company</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Released Year</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Genre</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Platform</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for game <- @games_page.entries do %>
                <tr class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= game.title %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= game.company %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= game.released_year %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= game.genre %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= game.platform %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div class="flex space-x-2">
                      <button
                        phx-click="edit-game"
                        phx-value-id={game.id}
                        class="text-blue-600 hover:text-blue-900"
                        title="Edit game"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                      <button
                        phx-click="delete-game"
                        phx-value-id={game.id}
                        data-confirm="Are you sure you want to delete this game?"
                        class="text-red-600 hover:text-red-900"
                        title="Delete game"
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
            <%= if @games_page.page_number > 1 do %>
              <.link
                navigate={~p"/admin/collection/games?page=#{@games_page.page_number - 1}"}
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              >
                Previous
              </.link>
            <% else %>
              <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-300 bg-white cursor-not-allowed">
                Previous
              </span>
            <% end %>

            <%= if @games_page.page_number < @games_page.total_pages do %>
              <.link
                navigate={~p"/admin/collection/games?page=#{@games_page.page_number + 1}"}
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
                Showing <span class="font-medium"><%= (@games_page.page_number - 1) * @games_page.page_size + 1 %></span> to <span class="font-medium"><%= min(@games_page.page_number * @games_page.page_size, @games_page.total_entries) %></span> of <span class="font-medium"><%= @games_page.total_entries %></span> results
              </p>
            </div>
            <div>
              <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                <%= if @games_page.page_number > 1 do %>
                  <.link
                    navigate={~p"/admin/collection/games?page=#{@games_page.page_number - 1}"}
                    class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <span class="sr-only">Previous</span>
                    <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </.link>
                <% end %>

                <%= for page_num <- max(1, @games_page.page_number - 2)..min(@games_page.total_pages, @games_page.page_number + 2) do %>
                  <%= if page_num == @games_page.page_number do %>
                    <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-blue-50 text-sm font-medium text-blue-600">
                      <%= page_num %>
                    </span>
                  <% else %>
                    <.link
                      navigate={~p"/admin/collection/games?page=#{page_num}"}
                      class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
                    >
                      <%= page_num %>
                    </.link>
                  <% end %>
                <% end %>

                <%= if @games_page.page_number < @games_page.total_pages do %>
                  <.link
                    navigate={~p"/admin/collection/games?page=#{@games_page.page_number + 1}"}
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
