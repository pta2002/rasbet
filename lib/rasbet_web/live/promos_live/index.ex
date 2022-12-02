defmodule RasbetWeb.PromosLive.Index do
  use RasbetWeb, :live_view

  alias Rasbet.Promotions.Promo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_promos()}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket |> push_patch(to: RasbetWeb.Router.Helpers.promos_index_path(socket, :index))}
  end

  @impl true
  def handle_event(
        "validate",
        %{"promo" => promo_params},
        %{assigns: %{current_user: %{is_admin: true}, promo: promo}} = socket
      ) do
    changeset =
      promo
      |> Promo.changeset(promo_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"promo" => promo_params},
        %{assigns: %{current_user: %{is_admin: true}, promo: promo}} = socket
      ) do
    res =
      promo
      |> Promo.changeset(promo_params)
      |> Rasbet.Repo.insert_or_update()

    case res do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Promoção criada com sucesso"))
         |> push_patch(to: RasbetWeb.Router.Helpers.promos_index_path(socket, :index))}

      :error ->
        {:noreply, socket |> put_flash(:error, gettext("Erro ao criar promoção"))}
    end
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{live_action: :create}} = socket) do
    {:noreply,
     socket
     |> assign(promo: %Promo{})
     |> assign(changeset: %Promo{} |> Promo.changeset(%{}))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp assign_promos(socket) do
    assign(socket, promos: Promo |> Rasbet.Repo.all())
  end
end
