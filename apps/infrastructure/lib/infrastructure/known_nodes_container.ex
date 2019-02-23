defmodule Infrastructure.KnownNodesContainer do
  use GenServer
  require Logger
  alias Infrastructure.ConnectionInfo

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## callbacks

  def init(_init_arg) do
    {:ok, [kown_nodes: [], connected_nodes: []]}
  end

  def handle_call({:add_address, address}, _from, [kown_nodes: kown_nodes, connected_nodes: connected_nodes]) do

    Logger.info "address in kown_nodes: #{address in kown_nodes}"
    case address in kown_nodes do
      true ->
        {:reply, {:allready_added, address}, [kown_nodes: kown_nodes, connected_nodes: connected_nodes]}
      false ->
        {:reply, {:ok, address}, [kown_nodes: [address | kown_nodes], connected_nodes: connected_nodes]}
    end
  end

  def handle_call(:list, _from, [kown_nodes: kown_nodes, connected_nodes: _connected_nodes] = state) do
    {:reply, kown_nodes, state}
  end

  def handle_call({:for_address, address}, _from, [kown_nodes: kown_nodes, connected_nodes: _connected_nodes] = state) do
    {:reply, Enum.filter(kown_nodes, fn x -> x != address end), state }
  end

  ## api

  @spec list() :: any()
  def list() do
    GenServer.call(__MODULE__, :list)
  end

  @spec add_address(any()) :: any()
  def add_address(%ConnectionInfo{} = address) do
    GenServer.call(__MODULE__, {:add_address, address})
  end

  def get_for(address) do
    GenServer.call(__MODULE__, {:for_address, address})
  end

  defp validate_uri(uri) do
    uri = URI.parse(uri)
    uri.scheme != nil && uri.host =~ "."
  end
end
