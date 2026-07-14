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
      # Start to serve requests, typically the last entry
      ItMinds.CvAgentWeb.Endpoint,
      # Start the Registry
      {Registry, keys: :unique, name: ItMinds.CvAgent.AgentRegistry},
      # start the DynamicSupervisor
      {ItMinds.CvAgent.AgentSupervisor, []}
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
