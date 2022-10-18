defmodule Rasbet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :type, :string
      add :value, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    alter table(:users) do
      add :balance, :integer
    end

    create index(:transactions, [:user_id])
  end
end
