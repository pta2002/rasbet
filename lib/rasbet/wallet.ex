defmodule Rasbet.Wallet do
  require Ecto.Query

  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet.Deposit
  alias Rasbet.Repo

  def change_deposit(%Deposit{} = deposit, attrs \\ %{}) do
    Deposit.changeset(deposit, attrs)
  end

  def deposit_user(user, deposit) do
    # TODO
  end

  def user_transactions(user) do
    Transaction
    |> Ecto.Query.where(user_id: ^user.id)
    |> Ecto.Query.order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
