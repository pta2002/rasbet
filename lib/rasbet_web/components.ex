defmodule RasbetWeb.Components do
  use Phoenix.Component
  import Phoenix.HTML.Form
  import RasbetWeb.ErrorHelpers

  def input(assigns) do
    ~H"""
      <div class="mb-4">
        <label for={@field} class="block mb-1"><%= @label %></label>
        <%= if @type == "phone" do %>
          <.country_input field={@field} form={@form} type={:phone}/>
        <% else %>
          <%= if @type == "country" do %>
            <.country_input field={@field} form={@form} type={:country}/>
          <% else %>
            <%= text_input @form,
              @field,
              id: @field,
              class: "input",
              type: @type
            %>
          <% end %>
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

  def country_input(assigns) do
    assigns = assigns |> Map.put(:countries, Enum.map(Countries.all(), &to_country/1))

    ~H"""
      <div
        class={"relative grid" <> if @type == :phone do " grid-cols-3 gap-4" else "grid-cols-1" end}
        x-data={"{
          open: false,
          selected: { emoji: '🇵🇹', code: '351', short: 'PT', name: 'Portugal' },
          #{if @type == :phone do "number: ''," else "" end}
          countries: #{Poison.encode!(@countries)},
          search: '',
          filtered: null,
          cursor: 0
        }"}>
        <div
          x-on:click="open = !open"
          x-on:keydown.enter.prevent = "open = !open"
          x-on:keydown.space.prevent = "open = !open"
          x-effect="
            if (open) {
              search = '';
              filtered = countries;
              cursor = 0;
              $nextTick(() => $refs.search.focus());
            }
          "
          tabindex="0"
          x-on:keydown.escape.window="open = false"
          class="input cursor-pointer flex items-center place-content-between">
          <div class="flex flex-row">
            <span x-text="selected.emoji"></span>
            <%= if @type == :phone do %>
              <span class="mx-2" x-text="'+' + selected.code"></span>
            <% else %>
              <span class="mx-2" x-text="selected.name"></span>
            <% end %>
          </div>
          <Heroicons.chevron_down class="w-4 h-4"/>
        </div>

        <div
          x-on:click.outside="open = false"
          x-cloak
          phx-update="ignore"
          id={@field}
          x-show="open"
          x-transition:enter="transition ease-out duration-100"
          x-transition:enter-start="transform opacity-0 scale-95"
          x-transition:enter-end="transform opacity-100 scale-100"
          x-transition:leave="transition ease-in duration-75"
          x-transition:leave-start="transform opacity-100 scale-100"
          x-transition:leave-end="transform opacity-0 scale-95"
          class={"absolute rounded-md px-4 py-2 flex gap-4 flex-col w-full bg-white border border-gray-300 shadow-sm" <> if @type == :phone do " mt-12" else " mt-2" end}>

          <input
            type="text"
            placeholder="Search"
            class="input"
            x-ref="search"
            x-model="search"
            x-on:keydown.enter.prevent.stop="if (cursor != 0) {
              selected = (filtered || countries)[cursor - 1];
              open = false;
            }"
            x-on:keydown.up.prevent="cursor = Math.max(0, cursor - 1)"
            x-on:keydown.down.prevent="cursor = Math.min(filtered.length, cursor + 1)"
            x-on:input="
              filtered = countries.filter(c => c.name.toLowerCase().startsWith(search.toLowerCase()));
              cursor = (filtered.length === 1 ? 1 : 0)
            " />

          <div class="max-h-40 flex flex-col overflow-scroll gap-1" tabindex="-1">
            <template x-for="(country, i) in (filtered || countries)">
              <span
                x-bind:class="'p-2 hover:bg-slate-200 rounded-md cursor-pointer' +
                  (selected.short === country.short ? ' bg-slate-300' : '') +
                  (cursor - 1 === i ? ' bg-slate-200' : '')"
                x-on:click="selected = country; open = false"
                x-effect="if (cursor === i + 1) $el.scrollIntoView()"
                x-text={"country.emoji + ' ' + country.name" <> if @type == :phone do "+ ' (+' + country.code + ')'" else "" end}
                x-bind:key="country.short">
              </span>
            </template>
          </div>
        </div>

        <%= if @type == :phone do %>
          <input type="text" x-model="number" class="input col-span-2"/>

          <%= text_input @form,
            @field,
            type: "hidden",
            "x-bind:value": "'+' + selected.code + number"
          %>
        <% else %>
          <%= text_input @form,
            @field,
            type: "hidden",
            "x-bind:value": "selected.short"
          %>
        <% end %>

      </div>
    """
  end
end
