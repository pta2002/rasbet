defmodule RasbetWeb.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  require Ecto.Query

  alias Rasbet.Accounts
  alias Rasbet.Accounts.User
  alias RasbetWeb.Router.Helpers, as: Routes

  def on_mount(:require_authenticated_user, _params, session, socket) do
    socket = assign_current_user(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "You have to sign in to continue")
         |> redirect(to: Routes.user_session_path(socket, :new))}

      %User{} ->
        {:cont, socket}
    end
  end

  def on_mount(:fetch_current_user, _params, session, socket) do
    %{assigns: %{current_user: user}} = socket = assign_current_user(socket, session)

    if connected?(socket) and user do
      RasbetWeb.Endpoint.subscribe("user:#{user.id}")
    end

    {:cont, socket}
  end

  def reassign_user(%{assigns: %{current_user: user}} = socket) do
    socket |> assign(current_user: User |> Ecto.Query.where(id: ^user.id) |> Rasbet.Repo.one!())
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      %{} ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
