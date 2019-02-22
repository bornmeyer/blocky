defmodule Blockchain.Container do
  use GenServer
  require Logger

  alias Blockchain.Block

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  defp via_id(id, registry_name) do
    {:via, Registry, {registry_name, id}}
  end

  @spec start_link(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(id, registry_name) do
    chosen_id = case id do
      nil -> via_id(UUID.uuid4(), registry_name)
      id -> via_id(id, registry_name)
    end
    {:via, Registry, {^registry_name, internal_id}} = chosen_id
    GenServer.start_link(__MODULE__, [id: internal_id, state: []], name: chosen_id)
  end

  ## callbacks

  @spec init([{:id, any()} | {:state, any()}, ...]) ::
          {:ok, [{:id, any()} | {:state, any()}, ...]}
  def init([id: id, state: state]) do
    {:ok, [id: id, state: state]}
  end

  def handle_cast({:validate, validator, callback, interval}, state) do
    Process.send_after(self(), {:validate, validator, callback, interval}, interval)
    {:noreply, state}
  end

  def handle_info({:validate, validator, callback, interval}, [id: id, state: state]) do
    case validator.(state |> sort) do
      false -> callback.({:error, state})
      true -> callback.(:ok)
    end
    Process.send_after(self(), {:validate, validator, callback, interval}, interval)
    {:noreply, [id: id, state: state]}
  end

  def handle_call({:append, payload}, _from, [id: id, state: state]) do
    new_block = create_block(payload, state)
    new_state = ([new_block] ++ state)
    {:reply, {:ok, id, new_state}, [id: id, state: new_state]}
  end

  def handle_call(:get_id, _from, [id: id, state: state]) do
    {:reply, {:ok, id}, [id: id, state: state]}
  end

  def handle_call(:list, _from, [id: id, state: state]) do
    result = state |> sort
    {:reply, {:ok, result}, [id: id, state: state]}
  end

  ## helpers

  defp create_block(payload, []) do
    Block.create payload: payload, timestamp: DateTime.utc_now() |> DateTime.to_unix
  end

  defp create_block(payload, [head | _]) do
    Block.create payload: payload, previous_block: head, timestamp: DateTime.utc_now() |> DateTime.to_unix
  end

  defp sort(list), do: Enum.sort(list, fn(x,y) -> x.index < y.index end)

  ## api

  @spec append(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, map()) :: any()
  def append(pid, payload) when is_map(payload) do
    GenServer.call(pid, {:append, payload})
  end

  @spec list(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def list(pid) do
    GenServer.call(pid, :list)
  end

  @spec get_id(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def get_id(pid) do
    result = case GenServer.call(pid, :get_id) do
      {:ok, id} -> id
    end
    result
  end

  @spec start_interval_validation(
          atom() | pid() | {atom(), any()} | {:via, atom(), any()},
          (any() -> any()),
          any()
        ) :: :ok
  def start_interval_validation(pid, validator, callback, interval \\ 500) when is_function(validator, 1) and is_function(callback, 1) do
    GenServer.cast(pid, {:validate, validator, callback, interval})
  end
end
