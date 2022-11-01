defmodule Rasbet.Game.Bet.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bet

  schema "bet_entries" do
    field :odds, :integer
    field :outcome, :string
    belongs_to :bet, Bet
    field :game, :id

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:outcome, :odds])
    |> validate_required([:outcome, :odds])
  end
end
