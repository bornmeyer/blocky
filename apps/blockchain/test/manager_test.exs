defmodule ManagerTest do
  use ExUnit.Case
  require Logger

  test "that you can create a new block chain" do
    new_id = "12345"
    {:ok, pid, id} = Blockchain.Manager.create_new_blockchain(new_id)
    assert Process.alive?(pid) && id == new_id
  end

  test "that you can find a blockchain via id" do
    new_id = "12345"
    {:ok, pid, id} = Blockchain.Manager.create_new_blockchain(new_id)
    assert pid == Blockchain.Manager.find_block_chain(new_id) && id == new_id
  end

  test "that you can append to a blockchain" do
    payload = %{test: "test"}
    blockchain_id = to_string(:rand.uniform)
    {:ok, pid, _} = Blockchain.Manager.create_new_blockchain(blockchain_id)
    Blockchain.Manager.append_to_blockchain(pid, payload)
    {:ok, blockchain} = Blockchain.Container.list(pid)
    actual = blockchain |> Enum.at(-1)
    assert payload == actual.payload
  end

  test "that you can validate a blockchain" do
    depth = :rand.uniform(100)
    blockchain_id = to_string(:rand.uniform)
    {:ok, pid, _} = Blockchain.Manager.create_new_blockchain(blockchain_id)
    Enum.to_list(0..depth) |> Enum.each(fn x -> Blockchain.Manager.append_to_blockchain(pid, %{test: x}) end)
    assert Blockchain.Manager.validate_chain(pid)
  end
end
