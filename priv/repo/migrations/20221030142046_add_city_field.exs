defmodule Rasbet.Repo.Migrations.AddCityField do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :city, :string, null: false, default: "City"
      modify :balance, :integer, null: false, default: 0
    end
  end
end
