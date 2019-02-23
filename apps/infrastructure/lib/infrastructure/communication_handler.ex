defmodule Infrastructure.CommunicationHandler do
  use GenServer
  alias Infrastructure.ConnectionInfo
  alias Infrastructure.Helpers
  alias Infrastructure.MessageProcessor
  @behaviour :ranch_protocol
  require Logger

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    IO.puts "Starting protocol"
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    response = Helpers.unpack(data)
    |> MessageProcessor.handle_message(socket, transport)
    |> Helpers.pack()
    transport.send(socket, response)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    IO.puts "Closing"
    transport.close(socket)
    {:stop, :normal, state}
  end

  def handle_info(test, state) do
    IO.inspect test
  end
end
