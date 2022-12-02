defmodule Rasbet.Game.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Accounts.User
  alias Rasbet.Wallet.Transaction

  schema "bets" do
    field :amount, Money.Ecto.Amount.Type, default: 0
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
    |> validate_required([:amount])
    |> validate_change(:amount, fn :amount, a ->
      unless Money.positive?(a) do
        [amount: "Montante a apostar tem de ser maior que 0"]
      else
        []
      end
    end)
    |> validate_change(:promo_id, fn :promo_id, promo_id ->
      promo = Rasbet.Promotions.Promo |> Rasbet.Repo.get_by(id: promo_id)

      case promo do
        nil -> [promo_id: RasbetWeb.ErrorHelpers.translate_error({"invalid promo id", []})]
        # TODO: Validar isto com as outras opções
        _promo -> []
      end
    end)
  end
end
