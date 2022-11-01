defmodule Rasbet.Game.TwoTeams.Info do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.TwoTeams.Info
  alias Rasbet.Repo

  require Ecto.Query

  schema "two_team_game_info" do
    field(:api_id, :string)
    field(:away_score, :integer)
    field(:away_team, :string)
    field(:home_score, :integer)
    field(:home_team, :string)
    field(:start_time, :utc_datetime)
    field(:completed, :boolean)
    field(:odds, :map)
    field(:sport, Ecto.Enum, values: Application.fetch_env!(:rasbet, :sports) |> Map.keys())

    timestamps()
  end

  @doc false
  def changeset(info, attrs) do
    info
    |> cast(attrs, [
      :api_id,
      :away_score,
      :away_team,
      :home_score,
      :home_team,
      :start_time,
      :completed,
      :odds,
      :sport
    ])
    |> validate_required([
      :api_id,
      :away_team,
      :home_team,
      :start_time,
      :completed,
      :odds,
      :sport
    ])
    |> unique_constraint(:api_id)
  end

  def list_games() do
    Info
    |> Ecto.Query.where(completed: false)
    |> Repo.all()
  end
end
