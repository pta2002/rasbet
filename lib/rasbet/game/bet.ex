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
    |> validate_change(:amount, fn :amount, a ->
      unless Money.positive?(a) do
        [amount: "Montante a apostar tem de ser maior que 0"]
      else
        []
      end
    end)
  end
end
