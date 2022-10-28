defmodule Rasbet.Wallet do
  require Ecto.Query

  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet.Deposit
  alias Rasbet.Accounts.User
  alias Rasbet.Repo
  alias Ecto.Multi

  def change_deposit(%Deposit{} = deposit, attrs \\ %{}) do
    Deposit.changeset(deposit, attrs)
  end

  def deposit_user(user, deposit) do
    # TODO
  end

  def apply_transaction(transaction) do
    Multi.new()
    |> Multi.insert(:transaction, transaction)
    |> Multi.update(:user, fn %{transaction: transaction} ->
      user =
        User
        |> Ecto.Query.where(id: ^transaction.user_id)
        |> Repo.one!()

      user
      |> Ecto.Changeset.change(
        balance: Money.add(user.balance || Money.new(0), transaction.value)
      )
    end)
    |> Repo.transaction()
  end

  def user_transactions(user) do
    Transaction
    |> Ecto.Query.where(user_id: ^user.id)
    |> Ecto.Query.order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
