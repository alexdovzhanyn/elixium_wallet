defmodule ActionHandler do
  alias Elixium.KeyPair
  alias Elixium.P2P.Peer

  def initialize do
    {:ok, message_handler} = MessageHandler.start_link()

    Peer.initialize(message_handler)

    main(message_handler)
  end

  def main(message_handler) do
    "What do you want to do? > "
    |> IO.gets()
    |> String.trim("\n")
    |> handle_action(message_handler)

    main(message_handler)
  end

  defp handle_action("transaction", message_handler) do
    recipient =
      "Recipient Public Key > "
      |> IO.gets()
      |> String.trim("\n")

    {amount, _} =
      "Amount to send > "
      |> IO.gets()
      |> String.trim("\n")
      |> Float.parse()

    {mining_fee, _} =
      "Mining Fee > "
      |> IO.gets()
      |> String.trim("\n")
      |> Float.parse()


    case Wallet.new_transaction(recipient, amount, mining_fee) do
      :not_enough_balance -> IO.puts("Not enough balance to send #{amount}.")
      transaction ->
        confirmation =
          "Send #{amount} to #{recipient} with a fee of #{mining_fee}? [Yn] > "
          |> IO.gets()
          |> String.trim("\n")

        if Enum.member?(["", "y", "Y"], confirmation) do
          IO.puts("Sending!")
          Peer.gossip("TRANSACTION", transaction)
        else
          IO.puts("Not sending.")
        end
    end
  end

  defp handle_action("new keypair", _) do
    {pub, priv} = KeyPair.create_keypair()

    IO.puts "Created keypair. Public key is #{Base.encode64(pub)}"
  end

  defp handle_action(_, _), do:   IO.puts "I don't know how to help with that."

end
