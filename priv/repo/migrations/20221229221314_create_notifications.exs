defmodule Rasbet.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :event, :string, null: false
      add :extra_data, :map
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :game_id, references(:games, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:game_id])
  end
end
