defmodule Rasbet.Repo.Migrations.AddIndexToGamesOdds do
  use Ecto.Migration

    def up do
    execute("CREATE INDEX two_team_game_info_odds ON two_team_game_info USING GIN(odds)")
  end

  def down do
    execute("DROP INDEX two_team_game_info_odds")
  end
end
