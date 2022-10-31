defmodule RasbetWeb.UserLive.Registration do
  use RasbetWeb, :live_auth

  alias Rasbet.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:changeset, Accounts.change_user_registration(%Accounts.User{}))}
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
         |> put_flash(:info, "Registado com sucess, já pode iniciar sessão")
         |> redirect(to: Routes.user_session_path(socket, :new))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:changeset, Map.put(changeset, :action, :validate))}
    end
  end

  def input(assigns) do
    ~H"""
      <div class="mb-4">
        <label for={@field} class="block mb-1"><%= @label %></label>
        <%= if @type == "phone" do %>
          <.phone_input field={@field} form={@form} />
        <% else %>
          <%= text_input @form,
            @field,
            id: @field,
            class: "block w-full bg-white rounded-md shadow-sm border-gray-300 focus:ring-primary-500 focus:border-primary-500 focus:outline-none",
            type: @type
          %>
        <% end %>
        <%= error_tag @form, @field %>
      </div>
    """
  end

  defp to_country(%{country_code: code, alpha2: short, name: name}) do
    %{
      code: code,
      short: short,
      name: name,
      emoji: short |> String.to_charlist() |> Enum.map(&(&1 - 65 + 127_462)) |> List.to_string()
    }
  end

  def phone_input(assigns) do
    assigns = assigns |> Map.put(:countries, Enum.map(Countries.all(), &to_country/1))

    ~H"""
      <div class="relative grid grid-cols-3 gap-4" x-data={"{
          open: false,
          selected: { emoji: '🇵🇹', code: '351', short: 'PT' },
          number: '',
          countries: #{Poison.encode!(@countries)},
          search: '',
          filtered: null,
          cursor: 0
        }"}>
        <div
          @click="open = !open"
          @keydown.enter.prevent = "open = !open";
          @keydown.space.prevent = "open = !open";
          x-effect="
            if (open) {
              search = '';
              filtered = countries;
              cursor = 0;
              $nextTick(() => $refs.search.focus())
            }
          "
          tabindex="0"
          @click.outside="open = false"
          @keydown.escape.window="open = false"
          class="cursor-pointer bg-white rounded-md shadow-sd border border-gray-300 focus:ring-primary-500 focus:border-primary-500 focus:outline-none flex items-center place-content-around px-2">
          <span x-text="selected.emoji"></span>
          <span class="mx-2" x-text="'+' + selected.code"></span>
          <Heroicons.chevron_down class="w-4 h-4"/>
        </div>

        <div
          x-cloak
          @blur="open = false;"
          x-show="open"
          x-transition:enter="transition ease-out duration-100"
          x-transition:enter-start="transform opacity-0 scale-95"
          x-transition:enter-end="transform opacity-100 scale-100"
          x-transition:leave="transition ease-in duration-75"
          x-transition:leave-start="transform opacity-100 scale-100"
          x-transition:leave-end="transform opacity-0 scale-95"
          class="absolute rounded-md px-4 py-2 flex gap-4 flex-col w-full mt-12 bg-white border border-gray-300 shadow-sm">

          <input
            type="text"
            placeholder="Search"
            class="input"
            x-ref="search"
            x-model="search"
            @keydown.enter.prevent.stop="if (cursor != 0) {
              selected = (filtered || countries)[cursor - 1];
              open = false;
            }"
            @keydown.up.prevent="cursor = Math.max(0, cursor - 1)"
            @keydown.down.prevent="cursor = Math.min(filtered.length, cursor + 1)"
            @input="filtered = countries.filter(c => c.name.toLowerCase().startsWith(search.toLowerCase()));
            cursor = (filtered.length === 1 ? 1 : 0)" />

          <div class="max-h-40 flex flex-col overflow-scroll gap-1" tabindex="-1">
            <template x-for="(country, i) in (filtered || countries)">
              <span
                x-bind:class="'p-2 hover:bg-slate-200 rounded-md cursor-pointer' +
                  (selected.short === country.short ? ' bg-slate-300' : '') +
                  (cursor - 1 === i ? ' bg-slate-200' : '')"
                @click="selected = country; open = false"
                x-effect="if (cursor === i + 1) $el.scrollIntoView()"
                x-text="country.emoji + ' ' + country.name + ' (+' + country.code + ')'"
                x-bind:key="country.short">
              </span>
            </template>
          </div>
        </div>

        <input type="text" x-model="number" class="input col-span-2"/>

        <%= text_input @form,
          @field,
          type: "hidden",
          "x-bind:value": "'+' + selected.code + number"
        %>

      </div>
    """
  end
end
