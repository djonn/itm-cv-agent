defmodule ItMinds.CvAgent.Repo do
  use Ecto.Repo,
    otp_app: :itm_cv_agent,
    adapter: Ecto.Adapters.Postgres
end
