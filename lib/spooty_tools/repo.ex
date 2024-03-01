defmodule SpootyTools.Repo do
  use Ecto.Repo,
    otp_app: :spooty_tools,
    adapter: Ecto.Adapters.Postgres
end
