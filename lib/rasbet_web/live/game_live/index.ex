defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams
  alias Rasbet.Repo
  alias Rasbet.Game.Bet

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, TwoTeams.Info.list_games())
     |> assign(:sports, Application.fetch_env!(:rasbet, :sports))
     |> assign(:bets, [])
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
         |> assign_odds()}

      :error ->
        {:noreply, socket |> put_flash(:error, "Incorrect game_id (you should never see this)")}
    end
  end

  def handle_event("delete_bet", %{"index" => i}, %{assigns: %{bets: bets}} = socket) do
    {:noreply,
     socket
     |> assign(:bets, List.delete_at(bets, String.to_integer(i)))
     |> assign_odds()}
  end

  def handle_event("update_amount", %{"bet" => %{"amount" => amount}}, socket) do
    money =
      case Float.parse(amount) do
        {a, _} -> round(a * 100)
        :error -> 0
      end

    changeset =
      %Bet{}
      |> Bet.changeset(%{amount: money})
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:bet, changeset |> Ecto.Changeset.apply_changes())
     |> assign_gains()
     |> assign(:amount, amount)
     |> assign(:changeset, changeset)}
  end

  defp assign_changeset(socket) do
    socket
    |> assign(:amount, "")
    |> assign(:bet, %Bet{amount: Money.new(0)})
    |> assign(:changeset, Bet.changeset(%Bet{}, %{}))
  end

  defp assign_gains(%{assigns: %{final_odd: odds, bet: %Bet{amount: amount}}} = socket) do
    socket
    |> assign(:gains, Money.multiply(amount, odds))
  end

  defp assign_odds(%{assigns: %{bets: bets}} = socket) do
    odds =
      Enum.map(bets, fn %{id: id, outcome: outcome} ->
        game = TwoTeams.Info |> Repo.get_by!(id: id)
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

  def sport_name(sport) do
    Application.fetch_env!(:rasbet, :sports)
    |> Map.get(sport)
  end

  def show_odds(odds) do
    case odds do
      %Decimal{} -> Decimal.to_float(odds)
      _ -> odds / 100
    end
    |> :erlang.float_to_binary(decimals: 2)
  end
end
