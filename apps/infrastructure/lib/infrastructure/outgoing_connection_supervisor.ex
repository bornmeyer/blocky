defmodule Infrastructure.OutgoingConnectionSupervisor do
  use Supervisor
  require Logger

  ## callbacks

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    ip = Application.get_env(:infrastructure, :outgoing_ip)
    port = Application.get_env(:infrastructure, :outgoing_port)
    children =  [
      Infrastructure.ConnectionHandler.child_spec([ip, port])
    ]
    Supervisor.init(children, strategy: :rest_for_one)
  end

  ## api

  def get_outgoing_connection() do
    Logger.info "test"
    Supervisor.which_children(__MODULE__) |> Enum.map(fn current ->
      {_, pid, _, _} = current
      pid
    end)
    |> Enum.at(0)
  end

end
