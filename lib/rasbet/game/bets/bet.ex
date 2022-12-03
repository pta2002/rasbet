defmodule Rasbet.Game.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Accounts.User
  alias Rasbet.Wallet.Transaction

  schema "bets" do
    # , default: Money.new(0)
    field :amount, Money.Ecto.Amount.Type
    belongs_to :user, User
    has_many :entries, Entry
    has_one :transaction, Transaction

    field :final_odds, :integer, virtual: true
    field :final_gains, Money.Ecto.Amount.Type, virtual: true
    field :possible_gains, Money.Ecto.Amount.Type, virtual: true

    field :completed, :boolean

    belongs_to :promo, Rasbet.Promotions.Promo

    timestamps()
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:amount, :promo_id])
    |> cast_assoc(:entries)
    |> validate_required([:amount])
    |> validate_change(:amount, fn :amount, a ->
      unless Money.positive?(a) do
        [
          amount:
            RasbetWeb.ErrorHelpers.translate_error(
              {"must be greater than %{number}", [number: 0]}
            )
        ]
      else
        []
      end
    end)
    |> validate_promo()
  end

  defp validate_promo(changeset) do
    amount = changeset |> get_field(:amount)

    changeset
    |> foreign_key_constraint(:promo_id)
    |> validate_change(:promo_id, fn :promo_id, id ->
      promo = Rasbet.Promotions.Promo |> Rasbet.Repo.get_by(id: id)

      case promo do
        nil ->
          [promo_id: RasbetWeb.ErrorHelpers.translate_error({"invalid promo id", []})]

        promo ->
          if Money.cmp(amount || Money.new(0), promo.minimum) == :lt do
            [
              amount:
                RasbetWeb.ErrorHelpers.translate_error(
                  {"must be greater than or equal to %{number}", [number: promo.minimum]}
                )
            ]
          else
            []
          end
      end
    end)
  end
end
