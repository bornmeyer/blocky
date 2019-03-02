defmodule Infrastructure.MessageProcessor do
  alias Infrastructure.ConnectionInfo
  alias Infrastructure.MessageSender

  require Logger

  defp create_connection_info(socket, listening_port) do
    with {:ok, {ip, _port}} <- :inet.peername(socket),
      {:ok, handler} <- Infrastructure.ConnectionSupervisor.create_connection(ip, listening_port) do
        %ConnectionInfo{ip: ip, port: listening_port, sender: handler, hash: create_hash(ip, listening_port)}
    end
  end

  defp create_connection_info([ip: ip, port: listening_port]) do
    with {:ok, handler} <- Infrastructure.ConnectionSupervisor.create_connection(ip, listening_port) do
      %ConnectionInfo{ip: ip, port: listening_port, sender: handler, hash: create_hash(ip, listening_port)}
    end
  end

  defp convert_ip(ip) when is_tuple(ip) do
    ip |> :inet_parse.ntoa |> to_string
  end

  defp convert_ip(ip) do
    ip |> to_charlist |> :inet.parse_address
  end

  defp create_hash(ip, port, hash_algorithm \\ :sha512) when is_tuple(ip) and is_integer(port) do
    data = "#{convert_ip(ip)}::#{to_string(port)}"
    :crypto.hash(hash_algorithm, data) |> Base.encode16
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

  def handle_message({:connected, nodes_to_connect_to}, _socket, _transport) when is_list(nodes_to_connect_to) do
    connect_to_received_nodes(nodes_to_connect_to)
  end

  defp connect_to_received_nodes([h|t]) do
    connection_info = create_connection_info(ip: h.ip, port: h.port)
    connection_info |> register_remote_address
    MessageSender.connect(connection_info.sender)
    connect_to_received_nodes(t)
  end

  defp connect_to_received_nodes([]) do

  end
end
