defmodule DailyTwang.Repo do
  use Ecto.Repo,
    otp_app: :daily_twang,
    adapter: Ecto.Adapters.Postgres
end
