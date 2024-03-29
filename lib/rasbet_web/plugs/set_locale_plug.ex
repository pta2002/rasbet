defmodule RasbetWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales Gettext.known_locales(RasbetWeb.Gettext)

  def init(_options), do: nil

  def call(conn, _options) do
    case fetch_locale_from(conn) do
      nil ->
        conn

      locale ->
        RasbetWeb.Gettext |> Gettext.put_locale(locale)

        conn
        |> put_resp_cookie("locale", locale, max_age: 365 * 24 * 60 * 60)
        |> put_session("locale", locale)
    end
  end

  def on_mount(:set_locale, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(RasbetWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:set_locale, _params, _session, socket), do: {:cont, socket}

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"])
    |> check_locale
  end

  defp check_locale(locale) when locale in @supported_locales, do: locale

  defp check_locale(_), do: nil
end
