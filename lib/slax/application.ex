defmodule Slax.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SlaxWeb.Telemetry,
      Slax.Repo,
      {DNSCluster, query: Application.get_env(:slax, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Slax.PubSub},
      {Finch, name: Slax.Finch},
      SlaxWeb.Presence,
      SlaxWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Slax.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    SlaxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
