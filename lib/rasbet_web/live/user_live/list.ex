defmodule RasbetWeb.UserLive.List do
  use RasbetWeb, :live_view

  alias Rasbet.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Gerir utilizadores"))
     |> assign_users()}
  end

  def assign_users(socket) do
    assign(
      socket,
      users:
        Rasbet.Accounts.User
        |> Rasbet.Repo.all()
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, list_users())}
  end

  defp list_users do
    Accounts.list_users()
  end
end
