defmodule Rasbet.Repo.Migrations.AddUserFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :name, :string, null: false, default: "Default Name"
      add :phone, :string, null: false, default: "+351912345678"
      add :taxid, :string, null: false, default: "123123123"
      add :address1, :string, null: false, default: "Rua"
      add :address2, :string, null: true
      add :country, :string, size: 2, default: "PT"
      add :zipcode, :string, default: "0000-000"
    end
  end
end
