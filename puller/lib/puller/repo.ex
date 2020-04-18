defmodule Puller.Repo do
  use Ecto.Repo,
    otp_app: :puller,
    adapter: Ecto.Adapters.Postgres
end
