defmodule RasbetWeb.Components.Notifications do
  use RasbetWeb, :live_component

  alias Rasbet.Accounts.Notifications

  @impl true
  def handle_event("clear_all", _params, %{assigns: %{current_user: user}} = socket) do
    Notifications.clear_notifications(user)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="h-full">
        <a class="nav-item cursor-pointer flex gap-2" x-on:click="notsOpen = !notsOpen">
          <%= if length(@current_user.notifications) == 0 do %>
            <Heroicons.bell class="w-7 h-7"/>
          <% else %>
            <Heroicons.bell solid class="w-7 h-7"/>
            <span class="bg-white text-primary-600 px-2 rounded-full"><%= length(@current_user.notifications) %></span>
          <% end %>
        </a>

        <div x-show="notsOpen" x-cloak x-on:click.outside="notsOpen = false" class="relative flex flex-col items-center">
          <div class="absolute top-0 flex flex-col items-center flex">
            <div class="w-5 h-5 -mb-3 rotate-45 bg-white shadow-md"></div>
            <div class="relative z-10 bg-white w-96 shadow-md rounded-lg text-black">
              <div class="flex place-content-between p-4 shadow-md">
                <h2 class="font-bold"><%= gettext "Notificações" %></h2>
                <a href="#" phx-click="clear_all" phx-target={@myself} class="font-medium text-primary-600"><%= gettext "Marcar todas como lidas" %></a>
              </div>

              <div class="h-96 overflow-y-scroll">
                <%= if length(@current_user.notifications) == 0 do %>
                  <div class="w-full h-full flex items-center justify-center">
                    <span class="font-medium text-xl text-gray-500"><%= gettext "Não tem notificações" %></span>
                  </div>
                <% else %>
                  <%= for notification <- @current_user.notifications do %>
                    <div class="flex flex-row p-4 gap-2 w-full">
                      <%= if notification.read do %>
                        <div class="rounded-full w-3 h-3 mt-1.5"></div>
                      <% else %>
                        <div class="rounded-full w-3 h-3 bg-primary-600 mt-1.5"></div>
                      <% end %>
                      <div class="w-full">
                        <h3 class="mb-2"><span class="font-medium"><%= notification.game |> Rasbet.Games.get_name() %></span> &mdash; <%= Rasbet.Accounts.Notifications.get_title(notification) %></h3>
                        <%= case notification.event do %>
                          <% :odds -> %>
                          <div class="grid grid-rows-1 grid-flow-col gap-2">
                            <%= for {outcome, odd} <- Map.get(notification.extra_data, "odds") do %>
                              <div class="bg-primary-500 rounded-md flex flex-col items-center justify-center text-white">
                                <div class="text-sm"><%= Gettext.gettext(RasbetWeb.Gettext, outcome) %></div>
                                <div class="font-bold"><%= show_odds odd %></div>
                              </div>
                            <% end %>
                          </div>

                          <% :started -> %>
                          <p><%= gettext "Um jogo que segue começou!" %></p>

                          <% :ended -> %>
                          <p>
                            <%= gettext "Um jogo que segue terminou!" %>
                            <%= gettext "Ganhou %{winnings}.", winnings: Money.new(Map.get(notification.extra_data, "winnings")) %>
                          </p>
                        <% end %>
                        <p class="text-gray-500 text-sm mt-1"><%= Calendar.strftime(notification.updated_at, gettext("%d/%m/%Y às %H:%M")) %></p>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
