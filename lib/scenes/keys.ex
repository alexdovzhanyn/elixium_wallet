defmodule ElixWallet.Scene.Keys do

    use Scenic.Scene
    alias Scenic.Graph
    alias Elixium.KeyPair
    alias Scenic.ViewPort
    alias ElixWallet.Utilities
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav

    @settings Application.get_env(:elix_wallet, :settings)


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
      get_keys()
      init_cache_files()
      push_graph(@graph)
      {:ok, %{graph: @graph, viewport: opts[:viewport]}}
    end

    defp init_cache_files() do
      Scenic.Cache.File.load(@gen_path, @gen_hash)
    end

    def get_keys() do
      Utilities.get_from_cache(:user_keys, "priv_keys")
    end

    def filter_event(event, _, graph) do
      {:continue, event, graph}
    end

    def filter_event({:click, :btn_import}, _, %{viewport: vp} = state) do
      ViewPort.set_root(vp, {ElixWallet.Scene.ImportKey, nil})
    end

    def filter_event({:click, :btn_export}, _, %{viewport: vp} = state) do
      keys = :ets.lookup(:user_keys, "priv_keys")
      priv_keys = Enum.map(keys, fn({_, v}) -> v end)
      :ets.insert(:scenic_cache_key_table, {"priv_keys", 1, priv_keys})
      ViewPort.set_root(vp, {ElixWallet.Scene.BackupKey, nil})
    end




  end
