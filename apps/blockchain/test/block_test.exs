defmodule BlockTest do
  use ExUnit.Case
  alias Blockchain.Block

  test "that when you create a new genesis block, its marked as genesis" do
    payload = %{test: "test", test2: "test2"}
    actual = Block.create(payload: payload, timestamp: DateTime.to_unix(DateTime.utc_now()))
    assert actual.type == "genesis"
  end

  test "that when you create a new genesis block, its previous hash is empty" do
    payload = %{test: "test", test2: "test2"}
    actual = Block.create(payload: payload, timestamp: DateTime.to_unix(DateTime.utc_now()))
    assert actual.previous_hash == ""
  end

  test "thath when you create a new genesis block, its payload equals the provided data" do
    payload = %{test: "test", test2: "test2"}
    actual = Block.create(payload: payload, timestamp: DateTime.to_unix(DateTime.utc_now()))
    assert actual.payload == payload
  end

  test "that when you create a new block, its previous hash is set accordingly" do
    payload = %{test: "test", test2: "test2"}
    genesis = Block.create(payload: payload, timestamp: DateTime.to_unix(DateTime.utc_now()))
    actual = Block.create(payload: payload, previous_block: genesis, timestamp: DateTime.to_unix(DateTime.utc_now()))
    assert actual.previous_hash == genesis.hash
  end

  test "that when you create a new genesis block, its marked as block" do
    payload = %{test: "test", test2: "test2"}
    genesis = Block.create(payload: payload, timestamp: DateTime.to_unix(DateTime.utc_now()))
    actual = Block.create(payload: payload, previous_block: genesis, timestamp: DateTime.to_unix(DateTime.utc_now()))
    assert actual.type == "block"
  end
end
