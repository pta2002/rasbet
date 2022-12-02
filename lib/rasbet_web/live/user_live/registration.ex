defmodule RasbetWeb.UserLive.Registration do
  use RasbetWeb, :live_auth

  alias Rasbet.Accounts

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:changeset, Accounts.change_user_registration(%Accounts.User{}))
     |> assign(:page_title, "Registar")}
  end

  def handle_info({:save, params}, socket) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :edit, &1)
          )

        cond do
          socket.assigns.live_action == :new ->
            {:noreply,
             socket
             |> put_flash(:info, "Registado com sucesso, já pode iniciar sessão")
             |> redirect(to: Routes.user_session_path(socket, :new))}

          true ->
            {:noreply,
             socket
             |> put_flash(:info, "Utilizador criado com sucesso")
             |> redirect(to: Routes.user_list_path(socket, :index))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, Map.put(changeset, :action, :validate))
         |> put_flash(:error, "Erro ao registar")}
    end
  end
end
