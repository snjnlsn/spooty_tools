defmodule SpootyTools.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SpootyToolsWeb.Telemetry,
      SpootyTools.Repo,
      {DNSCluster, query: Application.get_env(:spooty_tools, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SpootyTools.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SpootyTools.Finch},
      # Start a worker by calling: SpootyTools.Worker.start_link(arg)
      # {SpootyTools.Worker, arg},
      # Start to serve requests, typically the last entry
      SpootyToolsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpootyTools.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpootyToolsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
