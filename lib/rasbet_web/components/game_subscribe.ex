defmodule RasbetWeb.Components.GameSubscribe do
  use RasbetWeb, :live_component

  def render(assigns) do
    ~H"""
      <div x-data="{open: false}">
        <span class="flex underline gap-1 items-center cursor-pointer" x-on:click="open = !open">
          <%= gettext "Subscrever" %>
          <Heroicons.bell class="w-5 h-5"/>
        </span>

        <div
          x-show="open"
          x-cloak x-on:click.outside="open = false"
          class="relative flex flex-col items-center">
          <div class="absolute top-0 flex flex-col items-center flex">
            <div class="w-2 h-2 -mb-3 rotate-45 bg-white shadow-md"></div>
            <div class="relative z-10 mt-2 bg-white shadow-md rounded-lg text-black p-4 w-60">
              <span class="font-medium"><%= gettext "Receber notificações para:" %></span>
              <div class="flex flex-col mt-2">
                <span><input type="checkbox"> Começar</span>
                <span><input type="checkbox"> Mudança de odds</span>
                <span><input type="checkbox"> Terminar</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
