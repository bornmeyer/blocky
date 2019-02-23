defmodule Mix.Tasks.Infrastructure.Start do
  use Mix.Task
  require Logger

  @recursive true
  @shortdoc "starts the app and connects to a node"
  def run([ip, port | opts]) do
    {:ok, parsed_ip} = :inet.parse_address(to_charlist(ip))
    Application.put_env(:infrastructure, :outgoing_ip, parsed_ip, persistent: true)
    Application.put_env(:infrastructure, :outgoing_port, String.to_integer(port), persistent: true)
    Application.put_env(:infrastructure, :disable_initial_connect, false, persistent: true)
    Mix.Tasks.Run.run run_args() ++ opts
  end

  def run(args) do
    Application.put_env(:infrastructure, :disable_initial_connect, true, persistent: true)
    Mix.Tasks.Run.run run_args() ++ args
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?
  end
end
