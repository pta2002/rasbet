defmodule Rasbet.Repo.Migrations.ChangeBetTransaction do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :bet_id, references(:bets, on_delete: :delete_all)
    end

    alter table("bets") do
      remove :transaction
    end

    create index(:transactions, [:bet_id])
  end
end
