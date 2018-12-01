defmodule ElixWallet.NetworkHelpers do
  require Logger
  alias Elixium.Node.Supervisor, as: Peer
  alias Elixium.Node.ConnectionHandler
  alias Elixium.Store.Ledger
  alias ElixWallet.Utilities
  @default_block "000000243E564708D6133CFF3DC34F63A6ECC443885A44C168AAA30ED437A29E"



  def get_stats() do
    connected_peers = Peer.connected_handlers
    registered_peers = Peer.fetch_peers_from_registry(31013)
    ping_times = connected_peers |> Enum.map(fn peer ->
      Elixium.Node.ConnectionHandler.ping_peer(peer) end)
    store_latency(ping_times)

    case registered_peers do
      [] ->
        Utilities.store_in_cache(:peer_info, "registered_peers", 0)
      :not_found ->
        Utilities.store_in_cache(:peer_info, "registered_peers", 0)
      _->
        Utilities.store_in_cache(:peer_info, "registered_peers", Enum.count(registered_peers))
    end
    case connected_peers do
      [] ->
        Utilities.store_in_cache(:peer_info, "connected_peers", 0)
      :not_found ->
        Utilities.store_in_cache(:peer_info, "connected_peers", 0)
      _->
        Utilities.store_in_cache(:peer_info, "connected_peers", Enum.count(connected_peers))
        get_block_info()
    end
  end

  defp store_latency(times) do
    case times do
      [] ->
        Logger.info("No Network Latency found..")
      _->
      min_ping = Enum.min(times)
      max_ping = Enum.max(times)
      avg_ping = Enum.sum(times) / Enum.count(times)
      global_latency = scheduled_latency(times)
      Utilities.store_in_cache(:network_info, "latency_global", global_latency)
      Utilities.store_in_cache(:network_info, "latency", {avg_ping/1, min_ping/1, max_ping/1})
    end
  end


  def scheduled_latency(times) do
    0..9 |> Enum.map(fn id ->
      ping_time = Enum.fetch(times, id)
      case ping_time do
        {:ok, ping} ->
          {id+1, ping}
        :error ->
          {id+1, 999}
      end
    end)
  end

  defp get_last_blocks do
  block_range = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_n_blocks, [5]}, 20000) |> IO.inspect(label: "Last blocks")
    case block_range do
      :err ->
        Logger.info("Not Connected to Store Yet..")
        _->
        hash_list = block_range |> Enum.map(fn block -> block.hash end)
        Utilities.store_in_cache(:block_info, "last_blocks", hash_list)
    end
  end

  defp get_block_info() do
    last_block = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_block, []}, 20000)
    case last_block do
      :err ->
        difficulty = 0.0
        index = 0
      _->
        get_last_blocks
        set_blocks
        difficulty = last_block.difficulty/1
        index = :binary.decode_unsigned(last_block.index)
        Utilities.store_in_cache(:block_info, "block_info", {index, difficulty/1})
    end
  end

  defp set_blocks do
    bin_index = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_block, []}, 20000)
    case bin_index do
      :err ->
        Logger.info("Not Connected to Store Yet..")
      _->
      block_range = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_n_blocks, [120]}, 20000)
      calc_hash(block_range)
    end
  end

  defp calc_hash(blocks) do
    last_block = List.last(blocks)
    range = blocks |> Enum.reverse |> Enum.reduce_while([], fn block, acc ->
      valid_time(last_block, block)
    end)
    start_block = range |> List.first
    actual_blocks = :binary.decode_unsigned(last_block.index) - :binary.decode_unsigned(start_block.index)
    expected_blocks = 30
    hash = abs(actual_blocks / expected_blocks) * (last_block.difficulty/ 120)
    check_table_and_insert_hash(Kernel.round(hash)/1000)
  end

  defp valid_time(last_block, block) do
    if abs(last_block.timestamp - block.timestamp) <= 60*60 do
    {:cont, []}
    else
    {:halt, [block]}
  end

  end

  defp check_table_and_insert_hash(hash_rate) do
    hash_list = Utilities.get_from_cache(:network_info, "network_hash")
    nine_list = Enum.drop(hash_list, 1)
    reversed_list = Enum.reverse(nine_list)
    built_list = [hash_rate | reversed_list]
    temp_list = Enum.reverse(built_list)
    corrected_values = check_values(temp_list)
    Utilities.store_in_cache(:network_info, "network_hash", corrected_values)
  end

  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]), do: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, j]) do
    [1*(j/10), 2*(j/10), 3*(j/10), 4*(j/10), 5*(j/10), 6*(j/10), 7*(j/10), 8*(j/10), 9*(j/10), j]
  end
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, i, j]), do: [1*(i/10), 2*(i/10), 3*(i/10), 4*(i/10), 5*(i/10), 6*(i/10), 7*(i/10), 8*(i/10), i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, h, i, j]), do: [1*(h/10), 2*(h/10), 3*(h/10), 4*(h/10), 5*(h/10), 6*(h/10), 7*(h/10), h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, g, h, i, j]), do: [1*(g/10), 2*(g/10), 3*(g/10), 4*(g/10), 5*(g/10), 6*(g/10), g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, f, g, h, i, j]), do: [1*(f/10), 2*(f/10), 3*(f/10), 4*(f/10), 5*(f/10), f, g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, e, f, g, h, i, j]), do: [1*(e/10), 2*(e/10), 3*(e/10), 4*(e/10), e, f, g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, d, e, f, g, h, i, j]), do: [1*(d/10), 2*(d/10), 3*(d/10), d, e, f, g, h, i, j]
  defp check_values([0.0, 0.0, c, d, e, f, g, h, i, j]), do: [1*(d/10), 2*(d/10), c, d, e, f, g, h, i, j]
  defp check_values([0.0, b, c, d, e, f, g, h, i, j]), do: [1*(d/10), b, c, d, e, f, g, h, i, j]
  defp check_values([a, b, c, d, e, f, g, h, i, j]), do: [a, b, c, d, e, f, g, h, i, j]

end
