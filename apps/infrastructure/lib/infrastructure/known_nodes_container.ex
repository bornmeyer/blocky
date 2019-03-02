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
    {:ok, [known_nodes: [], connected_nodes: []]}
  end

  def handle_call({:add_address, address}, _from, [known_nodes: known_nodes, connected_nodes: connected_nodes]) do
    Logger.info "address in known_nodes: #{address in known_nodes}"
    case address in known_nodes do
      false ->
        Logger.info false
        {:reply, {:ok, address}, [known_nodes: [address | known_nodes], connected_nodes: connected_nodes]}
      true ->
        Logger.info true
        {:reply, {:allready_added, address}, [known_nodes: known_nodes, connected_nodes: connected_nodes]}
    end
  end

  def handle_call(:list, _from, [known_nodes: known_nodes, connected_nodes: _connected_nodes] = state) do
    {:reply, known_nodes, state}
  end

  def handle_call({:for_address, address}, _from, [known_nodes: known_nodes, connected_nodes: _connected_nodes] = state) do
    result = known_nodes |> Enum.filter(fn x -> x.hash != address.hash end)
    {:reply, result, state }
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

  def add_addresses(addresses) do
    known_addresses = list() |> Enum.map(fn x -> x.hash end)
    diff = addresses |> Enum.filter(fn x -> x.hash not in known_addresses end)
    append_to_state(diff, 0)
  end

  defp append_to_state([h|t], counter) do
    add_address(h)
    append_to_state(t, counter + 1)
  end

  defp append_to_state([], counter) do
    Logger.info fn -> "address-books merged (#{counter} entries)" end
  end

  def get_for(address) do
    GenServer.call(__MODULE__, {:for_address, address})
  end

  defp validate_uri(uri) do
    uri = URI.parse(uri)
    uri.scheme != nil && uri.host =~ "."
  end
end
