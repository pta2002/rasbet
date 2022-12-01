defmodule RasbetWeb.UserLive.Edit do
  use RasbetWeb, :live_view

  alias Rasbet.Accounts
  alias RasbetWeb.Components.UserSettings

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       changeset:
         Accounts.change_user_registration(
           socket.assigns.current_user
           |> Accounts.assign_user_phone()
         )
     )}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user_registration(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end
end
