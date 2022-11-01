defmodule Rasbet.Wallet.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rasbet.Accounts.User

  schema "transactions" do
    field :type, Ecto.Enum, values: [:deposit, :withdrawal, :bet, :betwinning]
    field :value, Money.Ecto.Amount.Type
    field :description, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :value, :description])
  end
end
