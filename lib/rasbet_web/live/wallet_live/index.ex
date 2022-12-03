defmodule RasbetWeb.WalletLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Wallet
  alias Rasbet.Wallet.Deposit
  alias Rasbet.Wallet.Withdrawal
  alias RasbetWeb.Router
  alias Rasbet.Promotions.Promo

  on_mount {RasbetWeb.LiveAuth, :require_authenticated_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_transactions()
     |> assign_deposit()
     |> assign_withdrawal()
     |> assign_changeset_deposit()
     |> assign_changeset_withdrawal()
     |> assign_promos()}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: RasbetWeb.Router.Helpers.wallet_index_path(socket, :index))}
  end

  @impl true
  def handle_event(
        "validate_d",
        %{"deposit" => deposit_params},
        %{assigns: %{deposit: deposit}} = socket
      ) do
    changeset_d =
      deposit
      |> Wallet.change_deposit(deposit_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset_d, changeset_d)}
  end

  @impl true
  def handle_event(
        "validate_w",
        %{"withdrawal" => withdrawal_params},
        %{assigns: %{withdrawal: withdrawal}} = socket
      ) do
    changeset_w =
      withdrawal
      |> Wallet.change_withdrawal(withdrawal_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset_w, changeset_w)}
  end

  @impl true
  def handle_event(
        "deposit",
        %{"deposit" => deposit_params},
        %{assigns: %{deposit: deposit, current_user: user}} = socket
      ) do
    changeset_d =
      deposit
      |> Wallet.change_deposit(deposit_params)
      |> Map.put(:action, :validate)

    if changeset_d.valid? do
      deposit = changeset_d |> Ecto.Changeset.apply_changes()

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
      {:noreply, socket |> assign(:changeset_d, changeset_d)}
    end
  end

  @impl true
  def handle_event(
        "withdrawal",
        %{"withdrawal" => withdrawal_params},
        %{assigns: %{withdrawal: withdrawal, current_user: user}} = socket
      ) do
    changeset_w =
      withdrawal
      |> Wallet.change_withdrawal(withdrawal_params)
      |> Map.put(:action, :validate)

    if changeset_w.valid? do
      withdrawal = changeset_w |> Ecto.Changeset.apply_changes()

      transaction = %Wallet.Transaction{
        type: :withdrawal,
        value: withdrawal.amount,
        user_id: user.id,
        description: "Levantamento"
      }

      Wallet.apply_transaction(transaction) |> Rasbet.Repo.transaction()

      {:noreply,
       socket
       |> put_flash(:success, "Levantou #{transaction.value}€")
       |> RasbetWeb.LiveAuth.reassign_user()
       |> assign_transactions()
       |> push_patch(to: Router.Helpers.wallet_index_path(socket, :index))}
    else
      {:noreply, socket |> assign(:changeset_w, changeset_w)}
    end
  end

  defp assign_transactions(%{assigns: %{current_user: user}} = socket) do
    socket |> assign(:transactions, user |> Wallet.user_transactions())
  end

  defp assign_deposit(socket) do
    socket |> assign(:deposit, %Deposit{})
  end

  defp assign_withdrawal(socket) do
    socket |> assign(:withdrawal, %Withdrawal{})
  end

  defp assign_changeset_deposit(%{assigns: %{deposit: deposit}} = socket) do
    socket |> assign(:changeset_d, Wallet.change_deposit(deposit))
  end

  defp assign_changeset_withdrawal(%{assigns: %{withdrawal: withdrawal}} = socket) do
    socket |> assign(:changeset_w, Wallet.change_withdrawal(withdrawal))
  end

  defp assign_promos(socket) do
    assign(socket, promos: Rasbet.Promotions.applicable_promotions())
  end
end
