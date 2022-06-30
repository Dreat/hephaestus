defmodule Hephaestus.Repo do
  use Ecto.Repo,
    otp_app: :hephaestus,
    adapter: Ecto.Adapters.Postgres
end
