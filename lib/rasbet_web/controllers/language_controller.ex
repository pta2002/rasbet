defmodule RasbetWeb.LanguageController do
  use RasbetWeb, :controller

  def update(conn, %{"locale" => locale}) do
    Gettext.put_locale(RasbetWeb.Gettext, locale)

    conn
    |> redirect(to: "/")
  end
end
