defmodule EPClass.Repo do
  use Ecto.Repo,
    otp_app: :elixir_phoenix_class,
    adapter: Ecto.Adapters.Postgres
end
