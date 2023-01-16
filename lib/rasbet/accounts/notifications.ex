defmodule Rasbet.Accounts.Notifications do
  use Phoenix.HTML
  import Ecto.Query

  alias Rasbet.Accounts.Notification
  alias Rasbet.Accounts.User

  def get_title(%Notification{event: event}) do
    case event do
      :started -> Gettext.gettext(RasbetWeb.Gettext, "Começou")
      :odds -> Gettext.gettext(RasbetWeb.Gettext, "Novas odds")
      :ended -> Gettext.gettext(RasbetWeb.Gettext, "Acabou")
    end
  end

  def clear_notifications(%User{id: id} = user) do
    from(n in Notification, where: n.user_id == ^id, update: [set: [read: true]])
    |> Rasbet.Repo.update_all([])

    RasbetWeb.Endpoint.broadcast(
      "user:#{user.id}",
      "update-user",
      user |> Map.put(:notifications, [])
    )
  end

  def send_notifications(notifications) do
    Task.async_stream(
      notifications,
      fn notification ->
        {:ok, notif} = Rasbet.Repo.insert(notification, returning: true)

        RasbetWeb.Endpoint.broadcast(
          "user:#{notification.user_id}",
          "new-notification",
          notif |> Rasbet.Repo.preload(:game)
        )
      end,
      ordered: false
    )
    |> Stream.run()
  end
end
