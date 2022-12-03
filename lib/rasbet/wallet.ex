defmodule Rasbet.Wallet do
  import Ecto.Query

  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet.Deposit
  alias Rasbet.Wallet.Withdrawal
  alias Rasbet.Accounts.User
  alias Rasbet.Repo
  alias Ecto.Multi

  def change_deposit(%Deposit{} = deposit, attrs \\ %{}) do
    Deposit.changeset_d(deposit, attrs)
  end

  def change_withdrawal(%Withdrawal{} = withdrawal, attrs \\ %{}) do
    Withdrawal.changeset_w(withdrawal, attrs)
  end

  def apply_transaction(transaction) do
    Multi.new()
    |> Multi.insert(:transaction, transaction)
    |> Multi.one(:user, fn %{transaction: %{user_id: user_id}} ->
      from(u in User, where: u.id == ^user_id)
    end)
    |> Multi.run(:new_balance, fn _repo, %{user: %{balance: bal}} ->
      bal = Money.add(bal, transaction.value)

      if Money.negative?(bal) do
        {:error, "Transação levaria a saldo negativo"}
      else
        {:ok, bal}
      end
    end)
    |> Multi.update(:update_user, fn %{new_balance: bal, user: user} ->
      user |> Ecto.Changeset.change(balance: bal)
    end)
    |> Multi.run(:send_message, fn _repo, %{update_user: user} ->
      RasbetWeb.Endpoint.broadcast("user:#{user.id}", "update-user", user)
      {:ok, nil}
    end)
  end

  def user_transactions(user) do
    Transaction
    |> Ecto.Query.where(user_id: ^user.id)
    |> Ecto.Query.order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
