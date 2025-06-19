defmodule Voli.Repo do
  use Ecto.Repo,
    otp_app: :voli,
    adapter: Ecto.Adapters.Postgres
end
