defmodule Rasbet.Repo.Migrations.AddPromoId do
  use Ecto.Migration

  def change do
    alter table("bets") do
      add :promo_id, references(:promos, on_delete: :nothing)
    end
  end
end
