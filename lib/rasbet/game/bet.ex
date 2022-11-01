defmodule Rasbet.Game.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bets" do
    field :amount, Money.Ecto.Amount.Type
    field :user_id, :id
    field :transaction, :id

    timestamps()
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
