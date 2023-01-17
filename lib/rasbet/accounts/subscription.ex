defmodule Rasbet.Accounts.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :user_id, :id
    field :game_id, :id
    field :events, {:array, Ecto.Enum}, values: [:started, :odds, :ended]

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:events, :game_id])
    |> validate_required([:game_id])
  end
end
