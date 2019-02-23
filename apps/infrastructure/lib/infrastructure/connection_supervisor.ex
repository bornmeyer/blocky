defmodule Infrastructure.ConnectionSupervisor do
  use DynamicSupervisor

  ## callbacks

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ## api

  def create_connection(ip, port) do
    child_spec = Infrastructure.ConnectionHandler.child_spec([ip, port, []])
    pid = case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    {:ok, pid}
  end

  def create_connection(existing_socket) do

  end
end
