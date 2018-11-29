defmodule ElixWallet do
  alias Elixium.Store.Ledger
  alias Elixium.Store.Utxo
  alias Elixium.Blockchain
  alias Elixium.P2P.Peer
  alias Elixium.Pool.Orphan
  alias ElixWallet.NetworkHelpers

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    main_viewport_config = Application.get_env(:elix_wallet, :viewport)
    setup_local_cache
    load_keys_to_cache()
    start_init()
    children = [
      supervisor(Scenic, viewports: [main_viewport_config]),
      {Elixium.Node.Supervisor, [:"Elixir.ElixWallet.PeerRouter", nil]},
      ElixWallet.PeerRouter.Supervisor,
      ElixWallet.NetworkHandler,
      ElixWallet.TransactionHandler
    ]
    Supervisor.start_link(children, strategy: :one_for_one)

  end

  def start_init() do
    Elixium.Store.Ledger.initialize()
    if Elixium.Store.Ledger.empty?() do
      Elixium.Store.Ledger.hydrate()
    end
    Elixium.Store.Utxo.initialize()
    ElixWallet.Store.Utxo.initialize()
    Elixium.Pool.Orphan.initialize()
    Elixium.Store.Oracle.start_link(Elixium.Store.Utxo)
    Elixium.Store.Oracle.start_link(ElixWallet.Store.Utxo)
    Elixium.Store.Oracle.start_link(Elixium.Store.Ledger)
    #ElixWallet.Supervisor.start_link
  end

  defp setup_local_cache do
    :ets.new(:user_keys, [:set, :public, :named_table, :bag])
    :ets.new(:user_info, [:set, :public, :named_table])
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
    {status, list_of_keyfiles} = choose_directory |> File.ls()
    keys = list_of_keyfiles
      |> Enum.map(fn file ->
        {priv, public} = Elixium.KeyPair.get_from_file(choose_directory <> "/" <> file)
        private = Base.encode16(priv)
        {private_display, tail} = String.split_at(private, 5)
        :ets.insert(:user_keys, {"priv_keys", {private_display, String.to_atom(private)}})
    end)
  end

  defp choose_directory() do
    settings = Application.get_env(:elix_wallet, :settings)
    case :os.type do
      {:unix, _} -> settings.unix_key_location
      {:win32, _} -> settings.win32_key_location
    end
  end


end
