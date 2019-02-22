defmodule Blockchain.Application do
  @blockchain_registry_name :blockchain_process_registry

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application



  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: @blockchain_registry_name},
      Blockchain.Manager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockchain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_registry_name, do: @blockchain_registry_name
end
