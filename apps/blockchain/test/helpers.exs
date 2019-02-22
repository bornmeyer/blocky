defmodule Test.Helpers do
  alias Blockchain.Block
  use Timex

  @test_data %{term: "test", value: 1}

  @spec create_chain(integer()) :: [any()]
  def create_chain(number_of_elements) do
    datetime = DateTime.utc_now()
    chain = Enum.to_list(0..number_of_elements) |> Enum.reduce([], fn(x, acc) ->
      case acc do
        [] -> [Block.create(payload: @test_data, timestamp: Timex.shift(datetime, seconds: x) |> DateTime.to_unix )]
        [head | _] -> [Block.create(payload: @test_data, previous_block: head, timestamp: Timex.shift(datetime, seconds: x) |> DateTime.to_unix) | acc]
      end
    end)
    chain |> sort
  end

  @spec sort(any()) :: [any()]
  def sort(list) do
    Enum.sort(list, fn(x,y) -> x.index < y.index end)
  end

  @spec invalidate_element(any(), [tuple()]) :: any()
  def invalidate_element(element, properties_to_change) do
    case properties_to_change do
      [head | tail] ->
        values = head |> Tuple.to_list
        element |> Map.put(values |> Enum.at(0), values |> Enum.at(1)) |> invalidate_element(tail)
      [] -> element
    end
  end
end

