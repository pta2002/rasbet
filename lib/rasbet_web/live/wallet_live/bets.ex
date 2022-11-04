defmodule RasbetWeb.WalletLive.Bets do
  use RasbetWeb, :live_view

  alias Rasbet.Game.Bets

  on_mount {RasbetWeb.LiveAuth, :require_authenticated_user}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign_bets()
     |> assign(
       :page_title,
       case socket.assigns.live_action do
         :index -> "Apostas ativas"
         :completed -> "Apostas concluídas"
       end
     )}
  end

  def assign_bets(%{assigns: %{live_action: action, current_user: user}} = socket) do
    bets =
      user
      |> Rasbet.Repo.preload(bets: [entries: :game])
      |> Map.get(:bets)
      |> Enum.map(&Bets.assign_odds/1)

    # case action do
    #   :index -> ["a"]
    #   :completed -> ["b"]
    # end

    socket |> assign(:bets, bets)
  end
end
