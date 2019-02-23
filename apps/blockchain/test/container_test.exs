defmodule ContainerTest do
  use ExUnit.Case
  alias Blockchain.Container
  require Logger

  @registry_name :blockchain_process_registry
  @payload %{test: "test"}

  test "that you can create a container" do
    id = to_string(:rand.uniform)
    {:ok, container} = Container.start_link(id, Blockchain.Application.get_registry_name())
    assert Process.alive?(container)
  end

  test "that a genesis block is automatically created as root" do
    id = to_string(:rand.uniform)
    {:ok, pid} = Container.start_link(id, Blockchain.Application.get_registry_name())
    {:ok, _id, new_state} = Container.append(pid, @payload)

    assert length(new_state) == 1 && Enum.count(new_state, fn x -> x.type == "genesis" end) == 1
  end

  test "that you can append blocks" do
    id = to_string(:rand.uniform)
    {:ok, pid} = Container.start_link(id, Blockchain.Application.get_registry_name())
    {:ok, _id, _new_state} = Container.append(pid, @payload)
    {:ok, _id, new_state} = Container.append(pid, @payload)

    assert length(new_state) == 2 && hd(new_state).type == "block" && Enum.at(new_state, 1).type == "genesis"
  end

  test "that you can get the id for a container" do
    expected = to_string(:rand.uniform)
    {:ok, pid} = Container.start_link(expected, Blockchain.Application.get_registry_name())
    actual = Container.get_id(pid)

    assert expected == actual
  end

  test "that an id is created if none is provided" do
    {:ok, pid} = Container.start_link(nil, Blockchain.Application.get_registry_name())
    id = Container.get_id(pid)
    assert id != nil && id != ""
  end
end
