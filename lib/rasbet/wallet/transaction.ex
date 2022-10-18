defmodule Rasbet.Wallet.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :type, Ecto.Enum, values: [:deposit, :withdrawal, :bet, :betwinning]
    field :value, :integer
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :value, :date])
  end
end
