defmodule BlockHelpersTest do
  use ExUnit.Case
  use Timex
  require Logger

  doctest Blockchain.BlockHelpers

  alias  Test.Helpers

  test "that genesis and follow up can be validated" do
    chain = Helpers.create_chain(1)
    chain |> Blockchain.BlockHelpers.validate_chain |> assert
  end

  test "that you can verify a chain" do
    number_elements = :rand.uniform(5)
    Helpers.create_chain(number_elements) |> Blockchain.BlockHelpers.validate_chain |> assert
  end

  test "that an invalid chain will not be verified" do
    number_of_elements = :rand.uniform(5)
    chain = Helpers.create_chain(number_of_elements)
    random_index = :rand.uniform(number_of_elements)
    invalid_element = chain |> Enum.at(random_index) |> Helpers.invalidate_element(hash: "1234", previous_hash: "5678")
    invalid_chain = [invalid_element | chain |> Enum.take(number_of_elements - random_index + 1)] |> Test.Helpers.sort
    actual = invalid_chain |> Blockchain.BlockHelpers.validate_chain
    assert !actual
  end

  test "that you can validate two blocks with each other" do
    chain = Helpers.create_chain(3)
    first_block = chain |> Enum.at(1)
    second_block = chain |> Enum.at(2)
    assert Blockchain.BlockHelpers.validate_chain([first_block, second_block])
  end

  test "that you can hash data" do
    data = "this is a test"
    expected = :crypto.hash(:sha512, data) |> Base.encode16
    actual = Blockchain.BlockHelpers.hash(data)
    assert actual == expected
  end

  test "that you can aggregate payload data" do
    payload = %{test: "test"}
    datetime = DateTime.to_unix(DateTime.utc_now)
    previous_hash = Blockchain.BlockHelpers.hash("test")
    expected = to_string(1) <> "test" <> previous_hash <> to_string(datetime)

    actual = Blockchain.BlockHelpers.aggregate_payload(1, payload, previous_hash, datetime)
    assert actual == expected
  end
end
