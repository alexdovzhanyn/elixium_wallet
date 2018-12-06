defmodule ElixiumWallet do
  alias Elixium.Store.Ledger
  alias Elixium.Store.Utxo
  alias Elixium.Blockchain
  alias Elixium.P2P.Peer
  alias Elixium.Pool.Orphan
  alias ElixiumWallet.NetworkHelpers
  alias ElixiumWallet.TransactionHelpers

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    main_viewport_config = Application.get_env(:elixium_wallet, :viewport)
    setup_local_cache
    load_keys_to_cache
    start_init()
    ElixiumWallet.Utilities.new_cache_transaction(%{id: "acbdefgh", valid?: true, amount: 111, status: "pending"},1.5, true)
    ElixiumWallet.Utilities.new_cache_transaction(%{id: "acbdefghi", valid?: true, amount: 111, status: "pending"},1.9, false)
    ElixiumWallet.Utilities.new_cache_transaction(%{id: "acbdefghj", valid?: true, amount: 111, status: "pending"},1.2, true)
    children = [
      supervisor(Scenic, viewports: [main_viewport_config]),
      {Elixium.Node.Supervisor, [:"Elixir.ElixiumWallet.PeerRouter", nil]},
      ElixiumWallet.PeerRouter.Supervisor,
      ElixiumWallet.NetworkHandler,
      ElixiumWallet.TransactionHandler
    ]
    Supervisor.start_link(children, strategy: :one_for_one)

  end

  def start_init() do
    Elixium.Store.Ledger.initialize()
    if !Elixium.Store.Ledger.empty?() do
      Elixium.Store.Ledger.hydrate()
    end
    Elixium.Store.Utxo.initialize()
    ElixiumWallet.Store.Utxo.initialize()
    Elixium.Pool.Orphan.initialize()
    Elixium.Store.Oracle.start_link(Elixium.Store.Utxo)
    Elixium.Store.Oracle.start_link(ElixiumWallet.Store.Utxo)
    Elixium.Store.Oracle.start_link(Elixium.Store.Ledger)
    #ElixiumWallet.Supervisor.start_link
  end

  defp setup_local_cache do
    :ets.new(:user_keys, [:set, :public, :named_table])
    :ets.new(:user_selection, [:set, :public, :named_table])
    :ets.new(:user_info, [:set, :public, :named_table])
    :ets.new(:transactions, [:public, :named_table])
    :ets.new(:block_info, [:set, :public, :named_table])
    :ets.new(:peer_info, [:set, :public, :named_table])
    :ets.new(:network_info, [:set, :public, :named_table])
    default_block = "000000243E564708D6133CFF3DC34F63A6ECC443885A44C168AAA30ED437A29E"
    :ets.insert(:block_info, {"last_blocks", [default_block, default_block, default_block, default_block, default_block]})
    :ets.insert(:block_info, {"block_info", {0, 0.0}})
    :ets.insert(:peer_info, {"registered_peers", 0})
    :ets.insert(:peer_info, {"connected_peers", 0})
    :ets.insert(:network_info, {"latency", {0.0, 0.0, 0.0}})
    :ets.insert(:network_info, {"latency_global", NetworkHelpers.scheduled_latency([0,0,0,0,0,0,0,0,0,0])})
    :ets.insert(:network_info, {"network_hash", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]})
    :ets.insert(:user_info, {"current_balance", 0.0})
  end

  defp load_keys_to_cache() do
    path =
      :elixium_core
      |> Application.get_env(:unix_key_address)
      |> Path.expand()
      

    {status, list_of_keyfiles} = File.ls(path)
    keys =
    case list_of_keyfiles do
      :enoent ->
        []
      key_files ->
        key_files |> Enum.map(fn file ->
          {public, private} = Elixium.KeyPair.get_from_file(path <> "/" <> file)
          Elixium.KeyPair.address_from_pubkey(public)
      end)
    end

    key_count = Enum.chunk_every(keys, 5) |> Enum.count
    :ets.insert(:user_keys, {"priv_keys", keys})
    :ets.insert(:user_keys, {"priv_count", key_count})
  end



  defp choose_directory() do
    settings = Application.get_env(:elixium_wallet, :settings)
    case :os.type do
      {:unix, _} -> settings.unix_key_location
      {:win32, _} -> settings.win32_key_location
    end
  end


end
