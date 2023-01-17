defmodule RasbetWeb.Components.GameSubscribe do
  use RasbetWeb, :live_component

  import Ecto.Query

  alias Rasbet.Accounts.Subscription

  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      subscription =
        case from(s in Subscription,
               where: s.game_id == ^assigns.game.id and s.user_id == ^assigns.user.id
             )
             |> Rasbet.Repo.one() do
          nil -> %Subscription{game_id: assigns.game.id, user_id: assigns.user.id, events: []}
          sub -> sub
        end

      Map.put(assigns, :changeset, Subscription.changeset(subscription, %{}))
      |> Map.put(:subscription, subscription)
    end)
  end

  def handle_event("update", %{"subscription" => subscription}, socket) do
    changeset = Subscription.changeset(socket.assigns.subscription, subscription)

    IO.inspect(changeset.data)

    case Rasbet.Repo.insert_or_update(changeset) do
      {:ok, res} ->
        {:noreply,
         assign(socket,
           changeset: changeset,
           subscription: res
         )}

      {:error, changeset} ->
        {:noreply,
         assign(socket,
           changeset: changeset
         )}
    end
  end

  def render(assigns) do
    ~H"""
      <div x-data="{open: false}">
        <span class="flex underline gap-1 items-center cursor-pointer" x-on:click="open = !open">
          <%= gettext "Subscrever" %>
          <%= if @subscription.events != nil and length(@subscription.events) > 0 do %>
            <Heroicons.bell solid class="w-5 h-5"/>
          <% else %>
            <Heroicons.bell class="w-5 h-5"/>
          <% end %>
        </span>

        <div
          x-show="open"
          x-cloak x-on:click.outside="open = false"
          class="relative flex flex-col items-center">
          <div class="absolute top-0 flex flex-col items-center flex">
            <div class="w-2 h-2 -mb-3 rotate-45 bg-white shadow-md"></div>
            <div class="relative z-10 mt-2 bg-white shadow-md rounded-lg text-black p-4 w-60">
              <.form :let={f} for={@changeset} phx-change="update" phx-target={@myself}>
                <div class="flex flex-col mt-2">
                  <.form_field
                    type="checkbox_group"
                    label={gettext("Receber notificaões para:")}
                    form={f}
                    field={:events}
                    class="mb-0"
                    options={[
                      {gettext("Começar"), :started},
                      {gettext("Mudança de odds"), :odds_changed},
                      {gettext("Terminar"), :ended}
                    ]}/>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
