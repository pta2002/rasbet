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
     |> assign_bet()
     |> assign_gains()
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
             bets ++
               [
                 %Rasbet.Game.Bets.Entry{game_id: game_id, outcome: outcome}
                 |> Repo.preload(:game)
                 |> Bets.assign_entry_odds()
               ]
           end
         )
         |> reassign_changeset_bets()
         |> assign_bet()
         |> assign_gains()
         |> assign_validity()}

      :error ->
        {:noreply, socket |> put_flash(:error, "Incorrect game_id (you should never see this)")}
    end
  end

  def handle_event("delete_bet", %{"index" => i}, %{assigns: %{bets: bets}} = socket) do
    {:noreply,
     socket
     |> assign(:bets, List.delete_at(bets, String.to_integer(i)))
     |> reassign_changeset_bets()
     |> assign_bet()
     |> assign_gains()
     |> assign_validity()}
  end

  def handle_event("validate", %{"bet" => params}, %{assigns: %{bets: bets}} = socket) do
    changeset =
      %Bet{entries: bets}
      |> Bet.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign_bet()
     |> assign_gains()
     |> assign(:amount, Map.get(params, "amount"))
     |> assign_validity()}
  end

  def handle_event(
        "bet",
        %{"bet" => bet},
        %{assigns: %{bets: bets, current_user: user}} = socket
      ) do
    if user do
      changeset =
        %Bet{user_id: user.id}
        |> Bet.changeset(bet)

      case Repo.transaction(Bets.place_bet(changeset, bets)) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(:bets, [])
           |> assign_changeset()
           |> assign_bet()
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

  def assign_bet(%{assigns: %{changeset: changeset, bets: entries}} = socket) do
    assign(
      socket,
      bet:
        changeset
        |> Ecto.Changeset.apply_changes()
        |> struct(entries: entries)
        |> Repo.preload([:promo, entries: [:game]])
        |> Rasbet.Game.Bets.assign_odds()
    )
  end

  defp assign_changeset(socket) do
    socket
    |> assign(:amount, "")
    # |> assign(:bet, %Bet{amount: Money.new(0), entries: [], promo: nil})
    |> assign(:changeset, Bet.changeset(%Bet{entries: [], promo: nil}, %{}))
    |> assign_bet()
    |> assign_validity()
  end

  def reassign_changeset_bets(%{assigns: %{bets: bets, bet: bet}} = socket) do
    assign(socket, bet: %Bet{bet | entries: bets})
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

  defp assign_gains(%{assigns: %{bet: bet}} = socket) do
    socket
    |> assign(:gains, bet |> Rasbet.Game.Bets.assign_odds() |> Map.get(:possible_gains))
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
