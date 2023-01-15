defmodule Rasbet.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :event, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :game_id, references(:games, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:game_id])
  end
end
