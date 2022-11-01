defmodule Rasbet.Repo.Migrations.CreateBetEntries do
  use Ecto.Migration

  def change do
    create table(:bet_entries) do
      add :outcome, :string, null: false
      add :odds, :integer, null: false
      add :bet_id, references(:bets, on_delete: :nothing), null: false
      add :game, references(:two_team_game_info, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:bet_entries, [:bet_id])
    create index(:bet_entries, [:game])
  end
end
