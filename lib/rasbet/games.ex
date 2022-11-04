defmodule Rasbet.Games do
  use Phoenix.HTML

  alias Rasbet.Game.TwoTeams.Info, as: Game

  def get_name(%Game{home_team: home, away_team: away}) do
    raw("#{home} &ndash; #{away}")
  end
end
