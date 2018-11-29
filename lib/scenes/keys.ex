defmodule ElixWallet.Scene.Keys do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Notes
    alias Elixium.KeyPair
    alias Scenic.ViewPort
    alias ElixWallet.Utilities
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav
    @theme Application.get_env(:elix_wallet, :theme)
    @settings Application.get_env(:elix_wallet, :settings)
    @notes "Random Note"
    @success "Generated Key Pair"

    @gen_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/baseline_add_circle_white_18dp.png")
    @gen_hash Scenic.Cache.Hash.file!( @gen_path, :sha )


    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
               |> text("", translate: {225, 150}, id: :event)
               |> text("", font_size: 12, translate: {200, 180}, id: :hint)
               |> text("KEY CONFIGURATION", id: :small_text, font_size: 26, translate: {425, 50})
               |> button("Import", id: :btn_import, width: 80, height: 46, theme: :dark, translate: {500, 200})
               |> button("Export", id: :btn_export, width: 80, height: 46, theme: :dark, translate: {750, 200})
               |> Nav.add_to_graph(__MODULE__)


    def init(_, opts) do
      viewport = opts[:viewport]
      {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
      get_keys()
      init_cache_files
      push_graph(@graph)
      {:ok, %{graph: @graph, viewport: opts[:viewport]}}
    end

    defp init_cache_files do
      Scenic.Cache.File.load(@gen_path, @gen_hash)
    end

    def get_keys() do
      keys = Utilities.get_from_cache(:user_keys, "priv_keys")
    end


    def filter_event({:click, :btn_import}, _, %{viewport: vp} = state) do
      ViewPort.set_root(vp, {ElixWallet.Scene.ImportKey, nil})
    end

    def filter_event({:click, :btn_export}, _, %{viewport: vp} = state) do
      keys = :ets.lookup(:user_keys, "priv_keys")
      priv_keys = Enum.map(keys, fn({k, v}) -> v end)
      :ets.insert(:scenic_cache_key_table, {"priv_keys", 1, priv_keys})
      ViewPort.set_root(vp, {ElixWallet.Scene.BackupKey, nil})
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    def filter_event(event, _, graph) do
      {:continue, event, graph}
    end

    defp check_and_write(full_path, {public, private}) do
      mnemonic = ElixWallet.Advanced.from_entropy(private)
      if !File.dir?(full_path), do: File.mkdir(full_path)
      address = Elixium.KeyPair.address_from_pubkey(public)
      with :ok <- File.write!(full_path<>"/#{address}.key", private) do
        {:ok, mnemonic}
      end
    end



  end
