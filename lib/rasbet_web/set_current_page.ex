defmodule RasbetWeb.SetCurrentPage do
  import Phoenix.Component

  def on_mount(:set_page, _params, _session, socket),
    do: {:cont, socket |> assign(:current_page, nil)}
end
