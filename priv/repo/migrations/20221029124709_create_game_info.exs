defmodule Rasbet.Repo.Migrations.CreateGameInfo do
  use Ecto.Migration

  def change do
    create table(:two_team_game_info) do
      add :api_id, :string
      add :home_team, :string, null: false
      add :away_team, :string, null: false
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false
      add :home_score, :integer, null: true
      add :away_score, :integer, null: true

      timestamps()
    end

    create unique_index(:two_team_game_info, [:api_id])
  end
end
