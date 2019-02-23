defmodule Infrastructure.MessageSender do
  alias Infrastructure.ConnectionHandler
  alias Infrastructure.Helpers

  def connect(socket) do
    ConnectionHandler.send(socket, {:connect, Application.get_env(:infrastructure, :port)} |> Helpers.pack())
  end

  def send({response_code, list, connection_info} = payload) do
    IO.inspect payload
    ConnectionHandler.send(connection_info.sender, {response_code, list} |> Helpers.pack())
  end

  def send(_) do

  end
end
