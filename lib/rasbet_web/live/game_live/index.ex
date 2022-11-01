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
     |> assign(:page_title, "Jogos")}
  end

  def handle_event(
        "add_bet",
        %{"game" => game_id_s, "outcome" => outcome},
        %{assigns: %{bets: bets}} = socket
      ) do
    case Integer.parse(game_id_s) do
      {game_id, _} ->
        {:noreply,
         socket
         |> assign(:bets, [%{id: game_id, outcome: outcome} | bets])
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

  defp assign_odds(%{assigns: %{bets: bets}} = socket) do
    socket
    |> assign(
      :bets_odds,
      Enum.map(bets, fn %{id: id, outcome: outcome} ->
        game = TwoTeams.Info |> Repo.get_by!(id: id)
        odd = game.odds[outcome]

        %{game: game, odd: odd, outcome: outcome}
      end)
    )
  end

  def sport_name(sport) do
    Application.fetch_env!(:rasbet, :sports)
    |> Map.get(sport)
  end
end
