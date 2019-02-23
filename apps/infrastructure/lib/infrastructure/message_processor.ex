defmodule Infrastructure.MessageProcessor do
  alias Infrastructure.ConnectionInfo
  alias Infrastructure.Helpers

  defp create_connection_info(socket) do
    with {:ok, {ip, port}} <- :inet.peername(socket),
      {:ok, handler} <- Infrastructure.ConnectionSupervisor.create_connection(ip, port) do
        %ConnectionInfo{ip: ip, port: port, sender: handler}
    end
  end

  defp register_remote_address(ip_with_port) do
    address = case Infrastructure.KnownNodesContainer.add_address(ip_with_port) do
      {:ok, address} -> address
      {:allready_added, address} -> address
    end
    address
  end

  def handle_message({:connect}, socket, _transport) do
    ip_with_port = create_connection_info(socket)


    register_remote_address(ip_with_port)
    |> Infrastructure.KnownNodesContainer.get_for()
  end

  def handle_message({:connected, nodes_to_connect_to}, _socket, _transport) do
    IO.inspect nodes_to_connect_to
  end
end
