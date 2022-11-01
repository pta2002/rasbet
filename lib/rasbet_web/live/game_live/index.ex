defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, TwoTeams.Info.list_games())
     |> assign(:sports, Application.fetch_env!(:rasbet, :sports))
     |> assign(:page_title, "Jogos")}
  end

  def sport_name(sport) do
    Application.fetch_env!(:rasbet, :sports)
    |> Map.get(sport)
  end
end
