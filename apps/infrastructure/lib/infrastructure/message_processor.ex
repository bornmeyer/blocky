defmodule Infrastructure.MessageProcessor do
  alias Infrastructure.ConnectionInfo

  require Logger

  defp create_connection_info(socket, listening_port) do
    with {:ok, {ip, _port}} <- :inet.peername(socket),
      {:ok, handler} <- Infrastructure.ConnectionSupervisor.create_connection(ip, listening_port) do
        %ConnectionInfo{ip: ip, port: listening_port, sender: handler}
    end
  end

  defp register_remote_address(ip_with_port) do
    address = case Infrastructure.KnownNodesContainer.add_address(ip_with_port) do
      {:ok, address} -> address
      {:allready_added, address} -> address
    end
    address
  end

  def handle_message({:connect, listening_port}, socket, _transport) do
    connection_info = create_connection_info(socket, listening_port)
    list = register_remote_address(connection_info)
      |> Infrastructure.KnownNodesContainer.get_for()
    {:connected, list, connection_info}
  end

  def handle_message({:connected, nodes_to_connect_to}, _socket, _transport) do
    Logger.info "#{length(nodes_to_connect_to)}\n lalalala"
  end
end
