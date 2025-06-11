defmodule Voli.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VoliWeb.Telemetry,
      Voli.Repo,
      {DNSCluster, query: Application.get_env(:voli, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Voli.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Voli.Finch},
      # Start a worker by calling: Voli.Worker.start_link(arg)
      # {Voli.Worker, arg},
      # Start to serve requests, typically the last entry
      VoliWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Voli.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VoliWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
