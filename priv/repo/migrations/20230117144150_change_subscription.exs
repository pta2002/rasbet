defmodule Rasbet.Repo.Migrations.ChangeSubscription do
  use Ecto.Migration

  def up do
    alter table(:subscriptions) do
      add :events, {:array, :string}, null: true, default: []
      remove :event
    end
  end

  def down do
    alter table(:subscriptions) do
      remove :events
      add :event, :string, null: false, default: "started"
    end
  end
end
