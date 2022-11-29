defmodule RasbetWeb.UserLive.Edit do
  use RasbetWeb, :live_view

  alias Rasbet.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(changeset: Accounts.change_user_registration(socket.assigns.current_user))}
  end
end
