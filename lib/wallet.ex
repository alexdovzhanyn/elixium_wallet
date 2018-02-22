defmodule Wallet do
  alias UltraDark.Transaction
  alias UltraDark.Utilities
  alias UltraDark.UtxoStore
  alias UltraDark.KeyPair
  alias Decimal, as: D

  @spec new_transaction(String.t, Decimal, Decimal) :: Transaction
  @doc """
    Creates a new Transaction with the specified parameters
  """
  def new_transaction(address, amount, desired_fee) do
    inputs = find_suitable_inputs(D.add(amount, desired_fee))
    designations = [%{amount: amount, addr: address}]

    designations = if D.cmp(Transaction.sum_inputs(inputs), D.add(amount, desired_fee)) == :gt do
      # Since a UTXO is fully used up when we put it in a new transaction, we must create a new output
      # that credits us with the change
      [%{amount: D.sub(Transaction.sum_inputs(inputs), D.add(amount, desired_fee)), addr: "MY OWN ADDR"} | designations]
    else
      designations
    end

    tx =
    %Transaction{
      designations: designations,
      inputs: inputs,
      timestamp: DateTime.utc_now |> DateTime.to_string
    }

    # The transaction ID is just the merkle root of all the inputs, concatenated with the timestamp
    id =
    Transaction.calculate_hash(tx) <> tx.timestamp
    |> (&(Utilities.sha_base16 &1)).()

    tx = %{tx | id: id}
    Map.merge(tx, Transaction.calculate_outputs(tx))
  end

  @doc """
    Return all UTXOs that are owned by the given public key
  """
  @spec find_pubkey_utxos(String.t) :: list
  def find_pubkey_utxos(public_key) do
    UtxoStore.find_by_address(public_key)
  end

  def find_wallet_utxos do
    {:ok, keyfiles} = File.ls(".keys")

    keyfiles
    |> Enum.flat_map(fn file ->
      {pub, priv} = KeyPair.get_from_file(".keys/#{file}")
      hex = pub |> Base.encode16

      find_pubkey_utxos(hex)
      |> Enum.map( &(Map.merge(&1, %{signature: KeyPair.sign(priv, &1.txoid) |> Base.encode16})) )
    end)
  end

  @doc """
    Take all the inputs that we have the necessary credentials to utilize, and then return
    the most possible utxos whos amounts add up to the amount passed in
  """
  @spec find_suitable_inputs(Decimal) :: list
  def find_suitable_inputs(amount) do
    find_wallet_utxos()
    |> Enum.sort(&(D.cmp(&1.amount, &2.amount) == :lt))
    |> take_necessary_utxos(amount)
  end

  defp take_necessary_utxos(utxos, amount), do: take_necessary_utxos(utxos, [], amount)
  defp take_necessary_utxos([utxo | remaining], chosen, amount) do
    case D.cmp(amount, 0) do
      :eq -> chosen
      :lt -> chosen
      _ -> take_necessary_utxos(remaining, [utxo | chosen], D.sub(amount, utxo.amount))
    end
  end
end
