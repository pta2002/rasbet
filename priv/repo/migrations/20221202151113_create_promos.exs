defmodule Rasbet.Repo.Migrations.CreatePromos do
  use Ecto.Migration

  def change do
    create table(:promos) do
      add :name, :string, null: false
      add :description, :string, null: false
      add :discount, :integer
      add :free_credits, :integer
      add :minimum, :integer, default: 0, null: false
      add :active, :boolean, default: true, null: false
      add :new_accounts_only, :boolean, default: false, null: false

      timestamps()
    end
  end
end
