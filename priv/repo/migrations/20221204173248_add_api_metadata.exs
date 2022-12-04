defmodule Rasbet.Repo.Migrations.AddApiMetadata do
  use Ecto.Migration

  def change do
    alter table("two_team_game_info") do
      add :game_source, :string, null: false, default: "ucras"
      add :api_info, :map, null: false, default: %{}
    end

    rename(table("two_team_game_info"), to: table("games"))
  end
end
