defmodule Rasbet.Repo.Migrations.CreateBets do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :amount, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :transaction, references(:transactions, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:bets, [:user_id])
    create index(:bets, [:transaction])
  end
end
