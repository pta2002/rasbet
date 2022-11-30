defmodule Rasbet.Wallet.Deposit do
  defstruct [:amount, :method]

  # TODO: Tentar usar o Money aqui
  @types %{
    amount: Money.Ecto.Amount.Type,
    method: {:parameterized, Ecto.Enum, Ecto.Enum.init(values: ~w(card mbway multibanco)a)}
  }

  alias Rasbet.Wallet.Deposit
  import Ecto.Changeset

  def changeset(%Deposit{} = deposit, attrs) do
    {deposit, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:amount, :method])
    |> validate_change(:amount, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end
end
