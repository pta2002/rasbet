defmodule Rasbet.Game.TwoTeams.Info do
  use Ecto.Schema
  import Ecto.Changeset

  schema "two_team_game_info" do
    field :api_id, :string
    field :away_score, :integer
    field :away_team, :string
    field :home_score, :integer
    field :home_team, :string
    field :start_time, :utc_datetime
    field :completed, :boolean

    timestamps()
  end

  @doc false
  def changeset(info, attrs) do
    info
    |> cast(attrs, [
      :api_id,
      :home_team,
      :away_team,
      :start_time,
      :end_time,
      :home_score,
      :away_score,
      :completed
    ])
    |> validate_required([
      :api_id,
      :home_team,
      :away_team,
      :start_time,
      :end_time,
      :completed
    ])
    |> unique_constraint(:api_id)
  end
end
