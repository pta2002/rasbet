defmodule RasbetWeb.WalletLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Wallet
  alias Rasbet.Wallet.Deposit
  alias RasbetWeb.Router

  on_mount {RasbetWeb.LiveAuth, :require_authenticated_user}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_transactions()
     |> assign_deposit()
     |> assign_changeset()}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: RasbetWeb.Router.Helpers.wallet_index_path(socket, :index))}
  end

  def handle_event(
        "validate",
        %{"deposit" => deposit_params},
        %{assigns: %{deposit: deposit}} = socket
      ) do
    changeset =
      deposit
      |> Wallet.change_deposit(deposit_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event(
        "deposit",
        %{"deposit" => deposit_params},
        %{assigns: %{deposit: deposit, current_user: user}} = socket
      ) do
    changeset =
      deposit
      |> Wallet.change_deposit(deposit_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      deposit = changeset |> Ecto.Changeset.apply_changes()

      transaction = %Wallet.Transaction{
        type: :deposit,
        value: deposit.amount,
        user_id: user.id,
        description: "Depósito"
      }

      Wallet.apply_transaction(transaction) |> Rasbet.Repo.transaction()

      {:noreply,
       socket
       |> put_flash(:success, "Depositou #{transaction.value}€")
       |> RasbetWeb.LiveAuth.reassign_user()
       |> assign_transactions()
       |> push_patch(to: Router.Helpers.wallet_index_path(socket, :index))}
    else
      {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  defp assign_transactions(%{assigns: %{current_user: user}} = socket) do
    socket |> assign(:transactions, user |> Wallet.user_transactions())
  end

  defp assign_deposit(socket) do
    socket |> assign(:deposit, %Deposit{})
  end

  defp assign_changeset(%{assigns: %{deposit: deposit}} = socket) do
    socket |> assign(:changeset, Wallet.change_deposit(deposit))
  end
end
