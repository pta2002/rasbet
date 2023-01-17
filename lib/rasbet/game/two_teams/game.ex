defmodule Rasbet.Game.TwoTeams.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.TwoTeams.Game
  alias Rasbet.Repo
  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Accounts.Subscription

  require Ecto.Query

  schema "games" do
    field(:api_id, :string)
    field(:away_score, :integer)
    field(:away_team, :string)
    field(:home_score, :integer)
    field(:home_team, :string)
    field(:start_time, :utc_datetime)
    field(:completed, :boolean)
    field(:odds, :map)
    field(:sport, Ecto.Enum, values: Application.fetch_env!(:rasbet, :sports) |> Map.keys())
    field(:game_source, :string)
    field(:api_info, :map)

    has_many(:entries, Entry)
    has_many(:bets, through: [:entries, :bet])
    has_many(:subscriptions, Subscription)

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
    Game
    |> Ecto.Query.where(completed: false)
    |> Ecto.Query.order_by(asc: :start_time)
    |> Repo.all()
  end
end
