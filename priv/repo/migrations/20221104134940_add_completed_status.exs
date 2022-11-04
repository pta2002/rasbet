defmodule Rasbet.Repo.Migrations.AddCompletedStatus do
  use Ecto.Migration

  def change do
    alter table("bets") do
      add :completed, :boolean, null: false, default: false
    end
  end
end
