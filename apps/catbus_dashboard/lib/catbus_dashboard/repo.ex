defmodule CatbusDashboard.Repo do
  use Ecto.Repo,
    otp_app: :catbus_dashboard,
    adapter: Ecto.Adapters.Postgres
end
