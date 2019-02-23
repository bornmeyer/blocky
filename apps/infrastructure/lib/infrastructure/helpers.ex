defmodule Infrastructure.Helpers do
  def unpack(data) do
    {:ok, unpacked} = Messagepack.decode(data)
    unpacked
  end

  def pack(data) do
    {:ok, packed} = Messagepack.encode(data)
    packed
  end
end
