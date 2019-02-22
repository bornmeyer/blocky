defmodule InfrastructureTest do
  use ExUnit.Case
  doctest Infrastructure

  test "greets the world" do
    assert Infrastructure.hello() == :world
  end
end
