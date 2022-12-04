defmodule Rasbet.APIs do
  @moduledoc """
  Serves as a Facade for all the APIs this implementation supports.

  Calling the update function will go through all APIs and call each one's update function individually.
  """

  def update() do
    Rasbet.APIs.UCRas.update()
  end
end
