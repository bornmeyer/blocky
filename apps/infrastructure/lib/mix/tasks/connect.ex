defmodule Mix.Tasks.Connect do
  use Mix.Task
  require Logger

  @recursive true
  @shortdoc "starts the app and connects to a node"
  def run([ip, port | opts]) do
    {:ok, started} = Application.ensure_all_started(:infrastructure)
    IO.inspect started
    Logger.info "Connecting to #{ip}:#{port}"
    case Infrastructure.Application.connect(ip, port) do
      {:ok, pid} -> Logger.info "connected"
    end
  end
end
