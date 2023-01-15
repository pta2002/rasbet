defmodule Rasbet.Accounts.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :event, Ecto.Enum, values: [:started, :ended, :odds]
    field :user_id, :id
    field :game_id, :id

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:event, :game_id])
    |> validate_required([:event, :game_id])
  end
end
