defmodule Rasbet.Repo.Migrations.AddOddsToGames do
  use Ecto.Migration

  def change do
    alter table(:two_team_game_info) do
      add :odds, :map, default: %{}
    end
  end
end
