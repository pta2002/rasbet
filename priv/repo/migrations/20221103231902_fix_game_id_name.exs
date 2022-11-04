defmodule Rasbet.Repo.Migrations.FixGameIdName do
  use Ecto.Migration

  def change do
    rename table("bet_entries"), :game, to: :game_id
  end
end
