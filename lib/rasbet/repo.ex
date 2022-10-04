defmodule Rasbet.Repo do
  use Ecto.Repo,
    otp_app: :rasbet,
    adapter: Ecto.Adapters.Postgres
end
