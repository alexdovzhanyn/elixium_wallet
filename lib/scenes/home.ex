defmodule ElixWallet.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort

  alias ElixWallet.Component.Nav

  @bg_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/bg.png")
  @bg_hash Scenic.Cache.Hash.file!(@bg_path, :sha )
  @font_path :code.priv_dir(:elix_wallet)
             |> Path.join("/static/fonts/museo.ttf")
  @font_hash Scenic.Cache.Hash.file!(@font_path, :sha )

  @theme Application.get_env(:elix_wallet, :theme)

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({80, 600}, translate: {0, 45}, fill: @theme.nav)
         |> rect({1024, 640}, translate: {0, 0}, fill: {:image, {@bg_hash, 15}})
         |> rect({300, 75}, fill: {10,10,10}, translate: {300, 100})
         |> text("Current Balance", width: 50, font: @font_hash, text_align: :center, translate: {200, 150})
         |> button("", id: :btn_stats, width: 50, height: 46, fill: :blue, translate: {200, 200})
         |> button("", id: :btn_balance, width: 50, height: 46, fill: :blue, translate: {200, 275})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    init_cache_files
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    push_graph(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  defp init_cache_files do
    Scenic.Cache.File.load(@bg_path, @bg_hash)
    Scenic.Cache.File.load(@font_path, @font_hash)
  end

  def filter_event({:click, :btn_balance}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Balance, nil})
    {:continue, {:click, :btn_balance}, state}
  end

  def filter_event({:click, :btn_stats}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Stats, nil})
    {:continue, {:click, :btn_stats}, state}
  end


end
