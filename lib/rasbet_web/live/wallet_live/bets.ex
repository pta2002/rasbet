defmodule RasbetWeb.WalletLive.Bets do
  use RasbetWeb, :live_view

  alias Rasbet.Game.Bets
  alias Rasbet.Game.Bets.Bet

  import Ecto.Query

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
      |> Rasbet.Repo.preload([
        {:bets,
         from(
           b in Bet,
           order_by: [desc: b.inserted_at],
           where: [completed: ^(action == :completed)]
         )},
        bets: [entries: :game]
      ])
      |> Map.get(:bets)
      |> Enum.map(&Bets.assign_odds/1)
      |> Enum.map(fn bet ->
        if bet.completed do
          Bets.assign_winnings(bet)
        else
          bet
        end
      end)

    socket |> assign(:bets, bets)
  end
end
