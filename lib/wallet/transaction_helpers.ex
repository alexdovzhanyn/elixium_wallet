defmodule ElixiumWallet.TransactionHelpers do
  alias Elixium.Transaction
  alias Elixium.Utilities
  alias Elixium.Node.Supervisor, as: Peer
  alias Elixium.Store.Utxo
  alias Elixium.KeyPair
  require Logger
  alias Decimal, as: D
  require IEx

  @settings Application.get_env(:elixium_wallet, :settings)

  def new_transaction(address, amount, desired_fee)  do
    amount = D.from_float(amount)
    desired_fee = D.from_float(desired_fee)
    tx =
    case find_suitable_inputs(D.add(amount, desired_fee)) do
      :not_enough_balance -> :not_enough_balance
      inputs ->
        previous_designations = [%{amount: amount, addr: address}]
        input_addresses =
          inputs
          |> Stream.map(fn input -> input.addr end)
          |> Enum.uniq
        own_address =  List.first(input_addresses)
        designations = Elixium.Transaction.create_designations(inputs, amount, desired_fee, own_address, previous_designations)
        tx_timestamp = Elixium.Transaction.create_timestamp
        tx =
          %Elixium.Transaction{
            inputs: inputs
          }
        id = Elixium.Transaction.create_tx_id(tx, tx_timestamp)
        tx = %{tx | id: id}
        transaction = Map.merge(tx, Transaction.calculate_outputs(tx, designations))
        sigs =
          Enum.uniq_by(inputs, fn input -> input.addr end)
          |> Enum.map(fn input -> Transaction.create_sig_list(input, transaction) end)
        transaction = Map.put(transaction, :sigs, sigs)
    end
  end

  def build_transaction(address, amount, fee) do
    Logger.info("Building Transaction")
    transaction = new_transaction(address, amount, fee)

    if transaction !== :not_enough_balance do
      ElixiumWallet.Utilities.new_cache_transaction(transaction, amount, :waiting)
    with true <- Elixium.Validator.valid_transaction?(transaction) do
      utxo_to_flag = transaction.inputs |> store_flag_utxos
      ElixiumWallet.Utilities.new_cache_transaction(transaction, amount, true)
      if Peer.gossip("TRANSACTION", transaction) == :ok do
        ElixiumWallet.Utilities.update_cache_transaction(transaction.id, transaction, amount, :confirmed)
      else
        ElixiumWallet.Utilities.update_cache_transaction(transaction.id, transaction, amount, :error)
    end
    end
    else
      ElixiumWallet.Utilities.new_cache_transaction(transaction, amount, false)
    :not_enough_balance
  end
  end

  @doc """
    Return all UTXOs that are owned by the given public key
  """
  @spec find_pubkey_utxos(String.t) :: list
  def find_pubkey_utxos(public_key) do
    #GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []})
  end

  def get_balance() do
    wallet = GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []}, 60000)
    flag = GenServer.call(:"Elixir.ElixiumWallet.Store.UtxoOracle", {:retrieve_all_utxos, []}, 60000)

    raw_balance =
      wallet -- flag
      |> Enum.reduce(0, fn utxo, acc -> acc + D.to_float(utxo.amount) end) |> IO.inspect(label: "Raw Balance")

    ElixiumWallet.Utilities.store_in_cache(:user_info, "current_balance", raw_balance/1)
  end

  def store_flag_utxos(utxos) do
    utxos |> Enum.each(&GenServer.call(:"Elixir.ElixiumWallet.Store.UtxoOracle", {:add_utxo, [&1]}, 500))
  end
  @doc """
    Take all the inputs that we have the necessary credentials to utilize, and then return
    the most possible utxos whos amounts add up to the amount passed in
  """
  @spec find_suitable_inputs(number) :: list
  def find_suitable_inputs(amount) do
    pool_utxo = GenServer.call(:"Elixir.Elixium.Store.UtxoOracle", {:retrieve_wallet_utxos, []}, 60000)
    flag_utxo = GenServer.call(:"Elixir.ElixiumWallet.Store.UtxoOracle", {:retrieve_all_utxos, []}, 60000)
    pool_utxo -- flag_utxo
    |> Enum.sort(&(:lt == D.cmp(&1.amount, &2.amount)))
    |> Transaction.take_necessary_utxos(amount)
  end
end
