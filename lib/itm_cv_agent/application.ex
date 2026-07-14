defmodule ItMinds.CvAgent.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ItMinds.CvAgentWeb.Telemetry,
      ItMinds.CvAgent.Repo,
      {DNSCluster, query: Application.get_env(:itm_cv_agent, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ItMinds.CvAgent.PubSub},
      # Start a worker by calling: ItMinds.CvAgent.Worker.start_link(arg)
      # {ItMinds.CvAgent.Worker, arg},
      # Start to serve requests, typically the last entry
      ItMinds.CvAgentWeb.Endpoint,
      ItMinds.CvAgent.AgentSupervisor
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ItMinds.CvAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ItMinds.CvAgentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
