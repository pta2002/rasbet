defmodule Rasbet.Repo.Migrations.AddLegalFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :birthdate, :date, [null: false, default: fragment("now()")]
      add :profession, :string, null: false, default: "Engenheiro Informático"
      add :id_number, :string, null: false, default: "11111"
    end

  end
end
