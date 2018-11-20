defmodule ElixWallet.Network.Helpers do
  require Logger

  def setup() do
    :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
    :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
    :ets.insert(:scenic_cache_key_table, {"latency", 1, {0.0, 0.0, 0.0}})
    :ets.insert(:scenic_cache_key_table, {"block_info", 1, {0, 0.0}})
    :ets.insert(:scenic_cache_key_table, {"latency_global", 1, scheduled_latency([0,0,0,0,0,0,0,0,0,0])})
    
  end


  def get_stats() do
    connected_peers = Elixium.P2P.Peer.connected_handlers
    registered_peers = Elixium.P2P.Peer.fetch_peers_from_registry(31013)

    ping_times = connected_peers |> Enum.map(fn peer ->
      Elixium.P2P.ConnectionHandler.ping_peer(peer) end) |> IO.inspect
    store_latency(ping_times)
    get_block_info()
    case registered_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, Enum.count(registered_peers)})
    end
    case connected_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, Enum.count(connected_peers)})
    end
  end

  defp store_latency(times) do
    case times do
      [] ->
        global_latency = scheduled_latency([0,0,0,0,0,0,0,0,0,0])
        :ets.insert(:scenic_cache_key_table, {"latency_global", 1, global_latency})
        :ets.insert(:scenic_cache_key_table, {"latency", 1, {999.9, 999.9, 999.9}})
      _->
      min_ping = Enum.min(times)
      max_ping = Enum.max(times)
      avg_ping = Enum.sum(times) / Enum.count(times)
      global_latency = scheduled_latency(times)
      :ets.insert(:scenic_cache_key_table, {"latency_global", 1, global_latency})
      :ets.insert(:scenic_cache_key_table, {"latency", 1, {avg_ping/1, min_ping/1, max_ping/1}})
    end
  end


  defp scheduled_latency(times) do
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

  defp get_block_info() do
    last_block = Elixium.Store.Ledger.last_block()
    if last_block !== :err do
    difficulty = last_block.difficulty/1
    case is_integer(difficulty) do
      true ->
        IO.puts "is int"
        difficutly = difficulty/1
      false ->
        difficulty
    end
    index = last_block.index
    :ets.insert(:scenic_cache_key_table, {"block_info", 1, {index, difficulty/1}})
    else
    difficulty = 0
    index = 0
    :ets.insert(:scenic_cache_key_table, {"block_info", 1, {index, difficulty/1}})
    end


  end

  #def get_ping_time(pid) do
  #  start = :erlang.timestamp()
  #  with :pang <- :net_adm.ping('tcpserver@') do
#
  #    ping = :timer.now_diff(:erlang.timestamp(), start)
  #    Logger.info("Sucessfully Pinged Node: #{ping*1000}")
  #    {:ok, {:erlang.node(pid), ping*1000}}
  #  else
    #  false ->
    #    ping = :timer.now_diff(:erlang.timestamp(), start)
    #    Logger.info("Warning Pinging Node: #{ping*1000}")
    #  {:error, {node(pid), ping*1000}}
    #end
  #end

end
