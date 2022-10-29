defmodule Rasbet.Repo.Migrations.AddCompletedField do
  use Ecto.Migration

  def change do
    alter table("two_team_game_info") do
      add :completed, :boolean, null: false
      remove(:end_time)
    end
  end
end
