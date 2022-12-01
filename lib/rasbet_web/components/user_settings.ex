defmodule RasbetWeb.Components.UserSettings do
  use RasbetWeb, :live_component

  alias Rasbet.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <div class={"grid grid-cols-1 md:grid-cols-2 md:gap-x-4 gap-y-1 grid-flow-col #{if @edit do "grid-rows-4" else "grid-rows-5" end}"}>
            <.input
              type="text"
              form={f}
              field={:name}
              label={gettext "Nome"}
              required
            />

            <.input
              type="email"
              form={f}
              field={:email}
              label={gettext "Email"}
              required
            />

            <.input
              type="phone"
              form={f}
              ccfield={:country_code}
              phonefield={:local_phone}
              label={gettext "Telemóvel"}
              required
            />

            <%= if not @edit do %>
              <.input
                type="password"
                form={f}
                field={:password}
                label={gettext "Palavra-passe"}
                required
              />

              <.input
                type="password"
                form={f}
                field={:password_confirmation}
                label={gettext "Confirmar palavra-passe"}
                required
              />
            <% end %>

            <.input
              type="text"
              form={f}
              field={:address1}
              label={gettext "Linha morada 1"}
              required
            />
            <.input
              type="text"
              form={f}
              field={:address2}
              label={gettext "Linha morada 2"}
            />
            <div class="grid grid-cols-2 gap-4">
              <.input
                type="text"
                form={f}
                field={:zipcode}
                label={gettext "Código postal"}
                required
              />
              <.input
                type="text"
                form={f}
                field={:city}
                label={gettext "Cidade"}
                required
              />
            </div>
            <.input
              type="country"
              form={f}
              field={:country}
              label={gettext "País"}
              required
            />
            <.input
              type="text"
              form={f}
              field={:taxid}
              label={gettext "NIF"}
              required
            />
        </div>

        <div class="flex place-content-between w-full items-center flex-row-reverse">
          <%= if @edit do %>
            <%= submit gettext("Editar"), class: "bg-primary-500 px-6 py-2 rounded-full text-white" %>
          <% else %>
            <%= submit gettext("Registar"), class: "bg-primary-500 px-6 py-2 rounded-full text-white" %>
            <div><%= gettext "Já tem conta?"%> <a href="/users/login" class="text-primary-500 font-semibold"><%= gettext "Entrar"%></a></div>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{user: user, edit: true} = assigns, socket) do
    changeset = Accounts.change_user_edit(user |> Accounts.assign_user_phone())

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def update(%{user: user, edit: false} = assigns, socket) do
    changeset = Accounts.change_user_registration(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> then(fn user ->
        if socket.assigns.edit do
          Accounts.change_user_edit(user, params)
        else
          Accounts.change_user_registration(user, params)
        end
      end)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    send(self(), {:save, params})
    {:noreply, socket}
  end
end
