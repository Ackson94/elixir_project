defmodule Proxy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Proxy.Repo,
      # Start the endpoint when the application starts
      ProxyWeb.Endpoint,
      # worker(Cachex, [:session, [:restart]]),
      # Proxy.Jobs.SessionManager,
      # Proxy.Scheduler,
      # {Task.Supervisor, name: Proxy.TaskSupervisor, restart: :transient}
      # Starts a worker by calling: Proxy.Worker.start_link(arg)
      # {Proxy.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ProxyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
