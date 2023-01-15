defmodule Rasbet.Accounts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :event, Ecto.Enum, values: [:started, :ended, :odds]
    field :extra_data, :map
    field :user_id, :id
    field :game_id, :id
    field :read, :boolean

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:event, :extra_data])
    |> validate_required([:event, :extra_data])
  end
end
