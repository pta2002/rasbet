defmodule RasbetWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use RasbetWeb, :controller
      use RasbetWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: RasbetWeb

      import Plug.Conn
      import RasbetWeb.Gettext
      alias RasbetWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/rasbet_web/templates",
        namespace: RasbetWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {RasbetWeb.LayoutView, "live.html"}

      use PetalComponents

      on_mount {RasbetWeb.LiveAuth, :fetch_current_user}
      on_mount {RasbetWeb.Plugs.SetLocale, :set_locale}
      on_mount {RasbetWeb.SetCurrentPage, :set_page}

      def handle_info(%{event: "update-user", payload: user}, socket) do
        {:noreply, socket |> assign(:current_user, user)}
      end

      def handle_info(
            %{event: "new-notification", payload: notification},
            %{assigns: %{current_user: u}} = socket
          ) do
        {:noreply,
         socket
         |> assign(:current_user, Map.put(u, :notifications, [notification | u.notifications]))}
      end

      unquote(view_helpers())
    end
  end

  def live_auth do
    quote do
      use Phoenix.LiveView,
        layout: {RasbetWeb.LayoutView, "auth.html"}

      use PetalComponents

      on_mount {RasbetWeb.Plugs.SetLocale, :set_locale}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import RasbetWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import RasbetWeb.ErrorHelpers
      import RasbetWeb.Gettext
      alias RasbetWeb.Router.Helpers, as: Routes

      alias Phoenix.LiveView.JS

      import RasbetWeb.Components

      use PetalComponents
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
