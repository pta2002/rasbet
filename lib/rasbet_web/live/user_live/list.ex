defmodule RasbetWeb.UserLive.List do
  use RasbetWeb, :live_view

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
end
