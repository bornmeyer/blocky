defmodule Blockchain.Manager do
  use DynamicSupervisor
  require Logger



  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) ::
          {:ok,
           %{
             extra_arguments: [any()],
             intensity: non_neg_integer(),
             max_children: :infinity | non_neg_integer(),
             period: pos_integer(),
             strategy: :one_for_one
           }}
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec create_new_blockchain(any()) :: {:ok, pid(), any()}
  def create_new_blockchain(id \\ nil) do
    interval = Application.get_env(:blockchain, :validation_interval) || 5000
    validation_callback = Application.get_env(:blockchain, :validation_callback) || &Blockchain.Manager.on_validated/1

    child_spec = Blockchain.Container.child_spec([id, :blockchain_process_registry])
    pid = case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    Blockchain.Container.start_interval_validation(pid, &Blockchain.BlockHelpers.validate_chain/1, validation_callback, interval)
    {:ok, pid, Blockchain.Container.get_id(pid)}
  end

  def on_validated(:ok) do
  end

  def on_validated({:error, _state} = result) do
    result |> inspect |> Logger.info
  end

  @spec find_block_chain(any()) :: any()
  def find_block_chain(id) do
    DynamicSupervisor.which_children(__MODULE__) |> Enum.map(fn current ->
      {_, pid, _, _} = current
      pid
    end) |>
    Enum.find(fn pid -> Blockchain.Container.get_id(pid) == id end)
  end

  @spec append_to_blockchain(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, map()) ::
          any()
  def append_to_blockchain(block_pid, payload) when is_map(payload) do
    Blockchain.Container.append(block_pid, payload)
  end

  @spec validate_chain(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def validate_chain(block_pid) do
    {:ok, block_chain} = Blockchain.Container.list(block_pid)
    Blockchain.BlockHelpers.validate_chain(block_chain)
  end
end
