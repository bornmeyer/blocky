defmodule Infrastructure.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Infrastructure.Worker.start_link(arg)
      # {Infrastructure.Worker, arg}
      Infrastructure.RanchListener.child_spec(),
      Infrastructure.KnownNodesContainer.child_spec([:ok]),
      Infrastructure.ConnectionSupervisor,
      Infrastructure.OutgoingConnectionSupervisor
      #
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infrastructure.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
