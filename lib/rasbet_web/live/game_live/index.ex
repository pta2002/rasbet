defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams

  def handle_info({:update_games}, socket) do
    case TwoTeams.Api.games() do
      {:ok, games} -> {:noreply, socket |> assign(:games, games)}
      {:error, _} -> {:noreply, socket |> assign(:games, "Erro ao carregar jogos")}
    end
  end

  def mount(_params, _session, socket) do
    # {:ok, games} = TwoTeams.Api.games()
    if connected?(socket) do
      send(self(), {:update_games})
    end

    {:ok, socket |> assign(:games, nil)}
  end
end
