defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams
  alias Rasbet.Repo

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, TwoTeams.Info.list_games())
     |> assign(:sports, Application.fetch_env!(:rasbet, :sports))
     |> assign(:bets, [])
     |> assign_odds()
     |> assign(:gains, Money.new(0))
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

  def handle_event(
        "update_amount",
        %{"bet" => %{"amount" => amount}},
        %{assigns: %{final_odd: odds}} = socket
      ) do
    money =
      case Float.parse(amount) do
        {a, _} -> Money.new(round(a * 100))
        :error -> Money.new(0)
      end

    {:noreply,
     socket
     |> assign(:gains, money |> Money.multiply(odds))}
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
