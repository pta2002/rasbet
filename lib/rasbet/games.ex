defmodule Rasbet.Games do
  use Phoenix.HTML

  alias Rasbet.Game.TwoTeams.Game

  def get_name(%Game{home_team: home, away_team: away}) do
    raw("#{home} &ndash; #{away}")
  end

  def get_outcome(%Game{
        home_team: home_team,
        home_score: home_score,
        away_team: away_team,
        away_score: away_score
      }) do
    cond do
      away_score == home_score -> "Draw"
      home_score > away_score -> home_team
      away_score > home_score -> away_team
    end
  end
end
