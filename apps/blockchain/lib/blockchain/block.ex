defmodule Blockchain.Block do
  defstruct index: 0, hash: "", created_at: nil, type: "block", payload: nil, previous_hash: ""

  require Logger
  alias Blockchain.BlockHelpers
  alias Blockchain.Block

  def create([payload: payload,  previous_block: previous_block, timestamp: timestamp] = data) when is_list(data) do
    index = previous_block.index + 1
    hash = BlockHelpers.aggregate_payload(index, payload, previous_block.hash, timestamp) |> BlockHelpers.hash
    %Block{
      index: index,
      hash: hash,
      created_at: timestamp,
      payload: payload,
      previous_hash: previous_block.hash}
  end

  def create([payload: payload, timestamp: timestamp] = data) when is_list(data)  do
    hash = BlockHelpers.aggregate_payload(1, payload, "", timestamp) |> BlockHelpers.hash
    %Block{
      index: 1,
      hash: hash,
      created_at: timestamp,
      payload: payload,
      previous_hash: "",
      type: "genesis"}
  end

  def verify(block, previous_block) do
    expected_hash = BlockHelpers.aggregate_payload(block.index, block.payload, previous_block.hash, block.created_at) |> BlockHelpers.hash
    expected_hash == block.hash
  end
end
