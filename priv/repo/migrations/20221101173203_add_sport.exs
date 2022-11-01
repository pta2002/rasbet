defmodule Rasbet.Repo.Migrations.AddSport do
  use Ecto.Migration

  def change do
    alter table("two_team_game_info") do
      add :sport, :string, null: false, default: "football"
    end

    create index("two_team_game_info", [:sport])
  end
end
