defmodule Overbooked.Repo do
  use Ecto.Repo,
    otp_app: :overbooked,
    adapter: Ecto.Adapters.Postgres
end
