defmodule AuthentificationSystemWeb.AdminSettingsLive do
  use AuthentificationSystemWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Admin - Settings",
      settings: %{
        site_name: "Authentication System",
        site_description: "A secure authentication system",
        maintenance_mode: false,
        registration_enabled: true,
        email_notifications: true,
        session_timeout: 30
      }
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">System Settings</h1>
          <p class="text-gray-600 mt-1">Configure system-wide settings and preferences</p>
        </div>
        <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Save Changes
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- General Settings -->
        <div class="lg:col-span-2 space-y-6">
          <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">General Settings</h3>
            </div>
            <div class="p-6 space-y-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Site Name</label>
                <input type="text" value={@settings.site_name} class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Site Description</label>
                <textarea rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"><%= @settings.site_description %></textarea>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Session Timeout (minutes)</label>
                <input type="number" value={@settings.session_timeout} class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">Feature Toggles</h3>
            </div>
            <div class="p-6 space-y-6">
              <div class="flex items-center justify-between">
                <div>
                  <h4 class="text-sm font-medium text-gray-900">Maintenance Mode</h4>
                  <p class="text-sm text-gray-500">Enable maintenance mode to restrict access</p>
                </div>
                <button class={if @settings.maintenance_mode, do: "bg-blue-600", else: "bg-gray-200"} class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors">
                  <span class={if @settings.maintenance_mode, do: "translate-x-6", else: "translate-x-1"} class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"></span>
                </button>
              </div>

              <div class="flex items-center justify-between">
                <div>
                  <h4 class="text-sm font-medium text-gray-900">User Registration</h4>
                  <p class="text-sm text-gray-500">Allow new users to register</p>
                </div>
                <button class={if @settings.registration_enabled, do: "bg-blue-600", else: "bg-gray-200"} class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors">
                  <span class={if @settings.registration_enabled, do: "translate-x-6", else: "translate-x-1"} class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"></span>
                </button>
              </div>

              <div class="flex items-center justify-between">
                <div>
                  <h4 class="text-sm font-medium text-gray-900">Email Notifications</h4>
                  <p class="text-sm text-gray-500">Send email notifications to users</p>
                </div>
                <button class={if @settings.email_notifications, do: "bg-blue-600", else: "bg-gray-200"} class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors">
                  <span class={if @settings.email_notifications, do: "translate-x-6", else: "translate-x-1"} class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"></span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="space-y-6">
          <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">Quick Actions</h3>
            </div>
            <div class="p-6 space-y-3">
              <button class="w-full text-left p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                  </svg>
                  <span class="text-sm font-medium text-gray-900">Export Settings</span>
                </div>
              </button>

              <button class="w-full text-left p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-green-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"></path>
                  </svg>
                  <span class="text-sm font-medium text-gray-900">Import Settings</span>
                </div>
              </button>

              <button class="w-full text-left p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-red-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                  </svg>
                  <span class="text-sm font-medium text-gray-900">Reset to Defaults</span>
                </div>
              </button>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">System Info</h3>
            </div>
            <div class="p-6 space-y-3">
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Version</span>
                <span class="text-sm font-medium text-gray-900">1.0.0</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Last Updated</span>
                <span class="text-sm font-medium text-gray-900">2 hours ago</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Database</span>
                <span class="text-sm font-medium text-gray-900">PostgreSQL</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
