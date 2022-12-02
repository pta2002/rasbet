defmodule Rasbet.Promotions.Promo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promos" do
    field :active, :boolean, default: false
    field :description, :string
    field :discount, :integer
    field :free_credits, Money.Ecto.Amount.Type
    field :minimum, Money.Ecto.Amount.Type
    field :name, :string
    field :new_accounts_only, :boolean, default: false

    field :type, Ecto.Enum, values: [:percent, :freebet], virtual: true
    field :value, :integer, virtual: true

    timestamps()
  end

  @doc false
  def changeset(percent_promo, attrs) do
    percent_promo
    |> cast(attrs, [
      :name,
      :description,
      :discount,
      :minimum,
      :active,
      :new_accounts_only,
      :type,
      :value
    ])
    |> validate_required([
      :name,
      :description
    ])
    |> validate_types()
    |> validate_change(:minimum, fn :minimum, minimum ->
      if Money.negative?(minimum) do
        [minimum: RasbetWeb.ErrorHelpers.translate_error({"must be positive", []})]
      else
        []
      end
    end)
  end

  defp validate_types(changeset) do
    changeset
    |> validate_required([:type, :value])
    |> then(fn changeset ->
      case get_change(changeset, :type) do
        nil ->
          changeset

        :percent ->
          changeset
          |> put_change(:discount, get_change(changeset, :value))
          |> validate_number(:value, greater_than: 0, less_than_or_equal_to: 100)

        :freebet ->
          {:ok, money} = Money.parse(get_change(changeset, :value))
          put_change(changeset, :free_credits, money)
      end
    end)
  end
end
