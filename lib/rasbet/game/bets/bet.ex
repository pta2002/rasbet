defmodule Rasbet.Game.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Accounts.User
  alias Rasbet.Wallet.Transaction

  schema "bets" do
    field :amount, Money.Ecto.Amount.Type
    belongs_to :user, User
    has_many :entries, Entry
    has_one :transaction, Transaction

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
