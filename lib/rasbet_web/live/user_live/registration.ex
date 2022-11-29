defmodule RasbetWeb.UserLive.Registration do
  use RasbetWeb, :live_auth

  alias RasbetWeb.Components.UserSettings
  alias Rasbet.Accounts

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:changeset, Accounts.change_user_registration(%Accounts.User{}))
     |> assign(:page_title, "Registar")}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.change_user_registration(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("register", %{"user" => params}, socket) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :edit, &1)
          )

        {:noreply,
         socket
         |> put_flash(:info, "Registado com sucesso, já pode iniciar sessão")
         |> redirect(to: Routes.user_session_path(socket, :new))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:changeset, Map.put(changeset, :action, :validate))}
    end
  end
end
