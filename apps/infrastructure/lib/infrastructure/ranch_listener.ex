defmodule Infrastructure.RanchListener do
  use GenServer
  require Logger

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(opts) do
    :ranch.start_listener(make_ref(), :ranch_tcp, [{:port, get_port()}], Infrastructure.CommunicationHandler, [])
    {:ok, opts}
  end

  defp get_port() do
    port = Application.get_env(:infrastructure, :port) || 5555 |> String.to_integer
    Logger.info port
    port
  end

end
