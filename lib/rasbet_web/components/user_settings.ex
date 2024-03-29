defmodule RasbetWeb.Components.UserSettings do
  use RasbetWeb, :live_component

  alias Rasbet.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @edit do %>
        <h2 class="text-2xl font-medium mb-4"><%= gettext "Informações básicas" %></h2>
      <% end %>
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <div class={"grid grid-cols-1 md:grid-cols-3 md:gap-x-4 gap-y-1 md:grid-flow-col grid-flow-row #{if @edit do "grid-rows-4" else "grid-rows-5" end}"}>
            <.input
              type="text"
              form={f}
              field={:name}
              label={gettext "Nome Completo"}
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
           <.input
              type="date"
              form={f}
              field={:birthdate}
              label={gettext "Data de Nascimento"}
              required
            />
            <.input
              type="text"
              form={f}
              field={:profession}
              label={gettext "Profissão"}
              required
            />
           <.input
              type="text"
              form={f}
              field={:id_number}
              label={gettext "Número Identificação Civil"}
              required
            />

        </div>

        <div class="flex place-content-between w-full items-center flex-row-reverse">
          <%= if @edit do %>
              <%= submit gettext("Confirmar"), class: "bg-primary-500 px-6 py-2 rounded-full text-white h-min-fit" %>
              <%= link "Apagar Conta", to: Routes.user_session_path(@socket,:delete), method: :delete, phx_click: "delete",  data: [confirm: "Are you sure?"], class: "text-red-600 w-full"%>
          <% else %>
            <%= submit gettext("Registar"), class: "bg-primary-500 px-6 py-2 rounded-full text-white" %>
            <div><%= gettext "Já tem conta?"%> <a href="/users/log_in" class="text-primary-500 font-semibold"><%= gettext "Entrar"%></a></div>
          <% end %>
        </div>
      </.form>

      <%= if @edit do %>
        <h2 class="text-2xl font-medium mt-8 mb-4"><%= gettext "Alterar password" %></h2>
        <.form let={f} for={@changeset_password} phx-submit="change_password" phx-target={@myself}>
          <div class={"grid grid-cols-1 md:grid-cols-3 md:gap-x-4 gap-y-1"}>
            <.input
              type="password"
              form={f}
              field={:old_password}
              label={gettext "Password Antiga"}
              required
              />
            <.input
              type="password"
              form={f}
              field={:new_password}
              label={gettext "Nova Password"}
              required
              />

            <.input
              type="text"
              form={f}
              field={:new_password_confirmation}
              label={gettext "Confirmar nova Password"}
              required
              />
          </div>
          <div class="flex place-content-between w-full items-center flex-row-reverse">
            <%= submit gettext("Mudar Password"), class: "bg-primary-500 px-6 py-2 rounded-full text-white h-min-fit" %>
          </div>
        </.form>
      <% end %>

    </div>
    """
  end

  @impl true
  def update(%{user: user, edit: true} = assigns, socket) do
    changeset = Accounts.change_user_edit(user |> Accounts.assign_user_phone())

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:changeset_password, Accounts.change_user_password(user))}
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

  @impl true
  def handle_event("change_password", %{"user" => _params}, socket) do
    # todo
    {:noreply, socket}
  end
end
