defmodule Infrastructure.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do

    Logger.warn Application.get_env(:infrastructure, :connect_on_start)
    children = create_children_specs(Application.get_env(:infrastructure, :connect_on_start))
    IO.inspect children
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infrastructure.Supervisor]
    result = Supervisor.start_link(children, opts)

    if Application.get_env(:infrastructure, :connect_on_start) do
      pid = Infrastructure.OutgoingConnectionSupervisor.get_outgoing_connection()
      Infrastructure.MessageSender.connect(pid)
    end
    result
  end

  defp create_children_specs(initial_connect_disabled) do
    children =[
      # Starts a worker by calling: Infrastructure.Worker.start_link(arg)
      # {Infrastructure.Worker, arg}
      Infrastructure.RanchListener.child_spec(),
      Infrastructure.KnownNodesContainer.child_spec([:ok]),
      Infrastructure.ConnectionSupervisor,
      #
    ]
    case initial_connect_disabled do
      false -> children
      true -> [Infrastructure.OutgoingConnectionSupervisor | children]
    end
  end
end
