defmodule ElixWallet.Helpers do
  alias Elixium.Transaction
  alias Elixium.Utilities
  alias Elixium.Store.Utxo
  alias Elixium.KeyPair
  alias Decimal, as: D
  require IEx

  @settings Application.get_env(:elix_wallet, :settings)


  def new_transaction(address1, amount, desired_fee)  do
    address = "EX07Fvnbj8RtCb6MhTnbbxGNUe99VH2YvMhrogp2dQWh96DttEbL5"
    amount = D.from_float(1.0)
    desired_fee = D.from_float(0.5)

    tx =
    case find_suitable_inputs(D.add(amount, desired_fee)) do
      :not_enough_balance -> :not_enough_balance
      inputs ->
        designations = [%{amount: amount, addr: address}]

        input_addresses =
          inputs
          |> Enum.map(fn input -> input.addr end)
          |> Enum.uniq
        own_address =  List.first(input_addresses)

        designations =
          case D.cmp(Transaction.sum_inputs(inputs), D.add(amount, desired_fee)) do
            :gt ->
              IO.puts "GT"
              # Since a UTXO is fully used up when we put it in a new transaction, we must create a new output
              # that credits us with the change
              [%{amount: D.sub(Transaction.sum_inputs(inputs), D.add(amount, desired_fee)), addr: own_address} | designations]
            :lt ->
                IO.puts "LT"
              designations |> IO.inspect
            :eq ->
                IO.puts "EQ"
              designations |> IO.inspect
          end

          #IO.inspect(designations, label: "DESIGNATIONS")
          #IO.inspect(fee, label: "fee")

        tx =
          %Transaction{
            inputs: inputs,
            timestamp: DateTime.utc_now |> DateTime.to_string
          }

        # The transaction ID is just the merkle root of all the inputs, concatenated with the timestamp
        id =
          Transaction.calculate_hash(tx) <> tx.timestamp
          |> Utilities.sha_base16()

        tx = %{tx | id: id}
        Map.merge(tx, Transaction.calculate_outputs(tx, designations))

    end
  end

  @doc """
    Return all UTXOs that are owned by the given public key
  """
  @spec find_pubkey_utxos(String.t) :: list
  def find_pubkey_utxos(public_key) do
    #GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []})
  end

  def setup do
    :ets.insert(:scenic_cache_key_table, {"current_balance", 1, 0.0})
  end

  def get_balance() do
    raw_balance =
      GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []}, 20000)
      |> Enum.reduce(0, fn utxo, acc -> acc + D.to_float(utxo.amount) end)
    :ets.insert(:scenic_cache_key_table, {"current_balance", 1, raw_balance/1})
  end



  @doc """
    Take all the inputs that we have the necessary credentials to utilize, and then return
    the most possible utxos whos amounts add up to the amount passed in
  """
  @spec find_suitable_inputs(number) :: list
  def find_suitable_inputs(amount) do
    GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []}, 20000)
    |> Enum.sort(&(:lt == D.cmp(&1.amount, &2.amount)))
    |> take_necessary_utxos(amount)
  end

  defp take_necessary_utxos(utxos, amount), do: take_necessary_utxos(utxos, [], amount)

  defp take_necessary_utxos(utxos, chosen, amount) do
    if D.cmp(amount, 0) == :gt do
      if utxos == [] do
        :not_enough_balance
      else
        [utxo | remaining] = utxos
        take_necessary_utxos(remaining, [utxo | chosen], D.sub(amount, utxo.amount))
      end
    else
      chosen
    end
  end
end
