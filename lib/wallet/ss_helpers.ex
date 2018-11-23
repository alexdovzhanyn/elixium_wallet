def build_transaction(address, amount, fee) do
  ready = 0..199 |> Enum.map(fn index -> auto_test(address, amount, fee, index) end)
  IO.inspect(ready, label: "TRANSACTIONS")

  choice = "What do you want to do? > "
  |> IO.gets()
  |> String.trim("\n")

  if choice == "y" do
    Enum.map(ready, fn transaction -> Elixium.P2P.Peer.gossip("TRANSACTION", transaction) end)
  end
  # |> Enum.map(fn transaction -> Elixium.P2P.Peer.gossip("TRANSACTION", transaction) end)
  #with :ok <- Elixium.P2P.Peer.gossip("TRANSACTION", transaction) do
  #  IO.inspect
#
  #end
end

def auto_test(address, amount, fee, index) do
  transaction = new_transaction(address, String.to_float(amount), String.to_float(fee))
  utxo_to_flag = transaction.inputs |> store_flag_utxos
  transaction
end

defp supersuceeded() do

  #return = List.first(designations) |> IO.inspect
  #to = List.last(designations) |> IO.inspect
  #designation_return = 0..299 |> Enum.map(fn index -> %{addr: return.addr, amount: D.new(1.0)} end)
  #designations = designation_return ++ [to]
end
