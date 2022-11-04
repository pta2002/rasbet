defmodule Rasbet.Game.Bets.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bets.Bet
  alias Rasbet.Game.TwoTeams.Info

  schema "bet_entries" do
    field :odds, :integer
    field :outcome, :string
    belongs_to :bet, Bet
    belongs_to :game, Info

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:outcome, :odds])
    |> validate_required([:outcome, :odds])
  end
end
