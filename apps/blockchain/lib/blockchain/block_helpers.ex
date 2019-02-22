defmodule Blockchain.BlockHelpers do
  require Logger
  alias Blockchain.Block


  @spec aggregate_payload(integer(), map(), binary(), integer()) :: binary()
  def aggregate_payload(index, payload, previous_hash, timestamp) when is_map(payload) and is_integer(timestamp) and is_integer(index) do
    aggregated_payload =
      Map.values(payload)
      |> Enum.join
    to_string(index) <> aggregated_payload <> previous_hash <> to_string(timestamp)
  end

  @spec hash(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | byte(),
              binary() | []
            ),
          any()
        ) :: binary()
  def hash(data, hash_algorithm \\ :sha512) do
    :crypto.hash(hash_algorithm, data) |> Base.encode16
  end

  @spec validate_chain([...]) :: any()
  def validate_chain([%{type: "genesis"} = genesis, %{type: "block"} = follow_up| tail]) do
    cond do
      length(tail) == 0 -> Block.verify follow_up, genesis
      true -> Block.verify(follow_up, genesis) && Blockchain.BlockHelpers.validate_chain([follow_up | tail])
    end
  end

  def validate_chain([
    %{type: "block"} = current_block,
    %{type: "block"} = follow_up | tail]) do
    cond do
      length(tail) == 0 -> Block.verify follow_up, current_block
      true -> Block.verify(follow_up, current_block) && Blockchain.BlockHelpers.validate_chain([follow_up | tail])
    end
  end

  def validate_chain([]), do: true

  def validate_chain([%{type: "genesis"}]), do: true
end
