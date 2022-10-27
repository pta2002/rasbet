defmodule Rasbet.Repo.Migrations.AddTransactionDescription do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :description, :string
    end
  end
end
