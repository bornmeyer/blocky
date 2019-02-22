defmodule ConsensusTest do
  use ExUnit.Case
  doctest Consensus

  test "greets the world" do
    assert Consensus.hello() == :world
  end
end
