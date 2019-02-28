defmodule Mix.Tasks.Infrastructure.Start do
  use Mix.Task
  require Logger

  #@recursive true
  @shortdoc "starts the app and connects to a node"
  def run(opts) do
    opts
    |> parse_args
    |> process

    Mix.Tasks.Run.run run_args() #++ opts
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?
  end

  defp process(opts) do
    opts |> IO.inspect
    ip = opts[:ip_out] || "127.0.0.1"
    outgoing_port = opts[:port_out] || 9000
    port = opts[:port] || 9001
    connect_on_start = opts[:connect_on_start] || false


    {:ok, parsed_ip} = ip |> to_charlist |> :inet.parse_address
    Application.put_env(:infrastructure, :outgoing_ip, parsed_ip, persistent: true)
    Application.put_env(:infrastructure, :outgoing_port, outgoing_port, persistent: true)
    Application.put_env(:infrastructure, :port, port, persistent: true)
    Application.put_env(:infrastructure, :connect_on_start, connect_on_start, persistent: true)
  end

  defp parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ ip_out: :string,
                                                 port_out: :integer,
                                                 port:   :integer,
                                                 connect_on_start: :boolean ])
    parse |> inspect |> Logger.warn
    case parse do
      { options       , _, _ } -> options
    end
  end
end
