defmodule Rasbet.Accounts.Notifications do
  use Phoenix.HTML
  alias Rasbet.Accounts.User
  alias Rasbet.Accounts.Notification

  def get_title(%Notification{event: event, game_id: game} = notification) do
    case event do
      :started -> Gettext.gettext(RasbetWeb.Gettext, "Começou")
      :odds -> Gettext.gettext(RasbetWeb.Gettext, "Novas odds")
      :ended -> Gettext.gettext(RasbetWeb.Gettext, "Acabou")
    end
  end
end
