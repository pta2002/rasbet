defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams
  alias Rasbet.Repo
  alias Rasbet.Game.Bets.Bet
  alias Rasbet.Game.Bets

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, TwoTeams.Game.list_games())
     |> assign(:sports, Application.fetch_env!(:rasbet, :sports))
     |> assign(:bets, [])
     |> assign_promos()
     |> assign_changeset()
     |> assign_odds()
     |> assign(:page_title, "Jogos")}
  end

  def handle_event(
        "toggle_bet",
        %{"game" => game_id_s, "outcome" => outcome},
        %{assigns: %{bets: bets}} = socket
      ) do
    case Integer.parse(game_id_s) do
      {game_id, _} ->
        index =
          Enum.find_index(bets, fn %{id: id, outcome: o} -> id == game_id and o == outcome end)

        {:noreply,
         socket
         |> assign(
           :bets,
           if index do
             List.delete_at(bets, index)
           else
             bets ++ [%{id: game_id, outcome: outcome}]
           end
         )
         |> assign_odds()
         |> assign_validity()}

      :error ->
        {:noreply, socket |> put_flash(:error, "Incorrect game_id (you should never see this)")}
    end
  end

  def handle_event("delete_bet", %{"index" => i}, %{assigns: %{bets: bets}} = socket) do
    {:noreply,
     socket
     |> assign(:bets, List.delete_at(bets, String.to_integer(i)))
     |> assign_odds()
     |> assign_validity()}
  end

  def handle_event("validate", %{"bet" => bet}, socket) do
    changeset =
      %Bet{}
      |> Bet.changeset(bet)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:bet, changeset |> Ecto.Changeset.apply_changes())
     |> assign_gains()
     |> assign(:amount, Map.get(bet, "amount"))
     |> assign(:changeset, changeset)
     |> assign_validity()}
  end

  def handle_event(
        "bet",
        %{"bet" => %{"amount" => amount}},
        %{assigns: %{bets: bets, current_user: user}} = socket
      ) do
    if user do
      money = parse_amount(amount)

      changeset =
        %Bet{user_id: user.id}
        |> Bet.changeset(%{user_id: user.id, amount: money})

      case Repo.transaction(Bets.place_bet(changeset, bets)) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(:bets, [])
           |> assign_changeset()
           |> assign_odds()
           |> put_flash(:info, "Bet successfully")}

        {:error, _, _, _} ->
          {:noreply, socket |> put_flash(:error, "Failed to place bet")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:info, "Inicie sessão para apostar")
       |> redirect(to: Routes.user_session_path(socket, :new))}
    end
  end

  defp parse_amount(amount) do
    case Float.parse(amount) do
      {a, _} -> Money.new(round(a * 100))
      :error -> Money.new(0)
    end
  end

  defp assign_changeset(socket) do
    socket
    |> assign(:amount, "")
    |> assign(:bet, %Bet{amount: Money.new(0)})
    |> assign(:changeset, Bet.changeset(%Bet{}, %{}))
    |> assign_validity()
  end

  defp assign_validity(%{assigns: %{bets: bets, changeset: changeset}} = socket) do
    socket
    |> assign(
      :valid?,
      case Ecto.Changeset.apply_action(changeset, :validate) do
        {:ok, _} -> length(bets) > 0
        {:error, _} -> false
      end
    )
  end

  defp assign_gains(%{assigns: %{final_odd: odds, bet: %Bet{amount: amount}}} = socket) do
    socket
    |> assign(:gains, Money.multiply(amount, odds))
  end

  defp assign_odds(%{assigns: %{bets: bets}} = socket) do
    odds =
      Enum.map(bets, fn %{id: id, outcome: outcome} ->
        game = TwoTeams.Game |> Repo.get_by!(id: id)
        odd = Decimal.new(1, game.odds[outcome], -2)

        %{game: game, odd: odd, outcome: outcome}
      end)

    socket
    |> assign(:bets_odds, odds)
    |> assign(
      :final_odd,
      Enum.reduce(odds, Decimal.new(1), fn %{odd: odd}, acc -> Decimal.mult(acc, odd) end)
    )
    |> assign_gains()
  end

  defp assign_promos(%{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(promos: Enum.map(Rasbet.Promotions.applicable_promotions(user), &{&1.name, &1.id}))
  end

  def sport_name(sport) do
    Application.fetch_env!(:rasbet, :sports)
    |> Map.get(sport)
  end
end
