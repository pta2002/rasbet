defmodule Rasbet.APIs do
  @moduledoc """
  Serves as a Facade for all the APIs this implementation supports.

  Calling the update function will go through all APIs and call each one's update function individually.
  """

  require Logger

  def update() do
    case Rasbet.APIs.UCRas.update() do
      {:ok, games} -> Enum.each(games, fn {q, d, g} -> Rasbet.Games.update_game(q, d, g) end)
      {:error, reason} -> Logger.error("Failed to fetch games", reason: reason)
    end
  end
end
