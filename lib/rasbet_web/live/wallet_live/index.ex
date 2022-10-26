defmodule RasbetWeb.WalletLive.Index do
  use RasbetWeb, :live_view

  on_mount {RasbetWeb.LiveAuth, :require_authenticated_user}

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)
    {:ok, assign(socket, :email, socket.assigns.current_user.email)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:noreply, assign(socket, :email, socket.assigns.email <> ".")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: RasbetWeb.Router.Helpers.wallet_index_path(socket, :index))}
  end
end
