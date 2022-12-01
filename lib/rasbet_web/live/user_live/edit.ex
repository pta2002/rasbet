defmodule RasbetWeb.UserLive.Edit do
  use RasbetWeb, :live_view

  alias Rasbet.Accounts
  alias RasbetWeb.Components.UserSettings

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Definições"))
    |> assign(:user, socket.assigns.current_user)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  def handle_info({:save, updated_user}, socket) do
    case socket.assigns.user
         |> Accounts.change_user_edit(updated_user)
         |> Rasbet.Repo.update() do
      {:ok, _user} ->
        {:noreply, socket |> put_flash(:info, gettext("Utilizador atualizado"))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, Map.put(changeset, :action, :validate))
         |> put_flash(:error, "Error")}
    end
  end
end
