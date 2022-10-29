defmodule RasbetWeb.GameLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Game.TwoTeams

  def mount(_params, _session, socket) do
    {:ok, games} = TwoTeams.Api.games()
    {:ok, socket |> assign(:games, games)}
  end
end
