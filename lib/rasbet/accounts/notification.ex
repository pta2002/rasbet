defmodule Rasbet.Accounts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :event, Ecto.Enum, values: [:started, :ended, :odds]
    field :extra_data, :map
    field :read, :boolean

    belongs_to :game, Rasbet.Game.TwoTeams.Game
    belongs_to :user, Rasbet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:event, :extra_data])
    |> validate_required([:event, :extra_data])
  end
end
