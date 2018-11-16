defmodule ElixWallet do
  alias Elixium.Store.Ledger
  alias Elixium.Store.Utxo
  alias Elixium.Blockchain
  alias Elixium.P2P.Peer
  alias Elixium.Pool.Orphan


  @settings Application.get_env(:elix_wallet, :settings)
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:elix_wallet, :viewport)
    IO.puts "This works once"
    load_keys_to_cache()
    # start the application with the viewport
    children = [
      supervisor(Scenic, viewports: [main_viewport_config]),
      ElixWallet.Peer.Supervisor
    ]
      #Ledger.initialize()
      #Utxo.initialize()
      #Orphan.initialize()
      start_init()
      #ActionHandler.initialize()
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp start_init() do
    Elixium.Store.Ledger.initialize()

    if Elixium.Store.Ledger.empty?() do
  #    Elixium.Store.Ledger.append_block(Elixium.Block.initialize())
  #  else
      Elixium.Store.Ledger.hydrate()
    end

    Elixium.Store.Utxo.initialize()
    Elixium.Pool.Orphan.initialize()
  end

  defp load_keys_to_cache() do
    :ets.new(:user_keys, [:set, :protected, :named_table, :bag])
    {status, list_of_keyfiles} = choose_directory |> File.ls()
    keys = list_of_keyfiles |> Enum.map(fn file ->
      {priv, public} = Elixium.KeyPair.get_from_file(choose_directory<>"/"<>file)
      private = Base.encode16(priv)
      {private_display, tail} = String.split_at(private, 5)
      :ets.insert(:user_keys, {"priv_keys", {private_display, String.to_atom(private)}})
    end)
  end
  defp choose_directory() do
    case :os.type do
      {:unix, _} -> @settings.unix_key_location
      {:win32, _} -> @settings.win32_key_location
    end
  end
end
