defmodule Rasbet.Wallet.Withdrawal do
  defstruct [:amount, :iban]

  # TODO: Tentar usar o Money aqui
  @types %{
    amount: Money.Ecto.Amount.Type,
    iban: :string
  }

  alias Rasbet.Wallet.Withdrawal
  import Ecto.Changeset
  import ExIban.EctoValidator

  def changeset_w(%Withdrawal{} = withdrawal, attrs) do
    {withdrawal, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:amount, :iban])
    |> validate_iban(:iban)
    |> validate_change(:amount, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end
end
