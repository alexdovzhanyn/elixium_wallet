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

  @tips """
        Welcome to Elixium Wallet!
        Here you can Send, Receive your XEX, generate new keys
        and check the status of the Elixium Network
        """

@news_feed """
    Fast transactions, #anonymized network, and #Javascript contracts -- the perfect trio.
    We're building something you won't want to miss out on, so join us on the journey!
    http://t.me/elixiumnetwork  #blockchain #Elixium
  """

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({1024, 640}, translate: {0, 0}, fill: {:image, {@bg_hash, 15}})
         |> text("Elixium News", fill: @theme.nav, font_size: 26, translate: {150, 100})
         |> text(@news_feed, fill: @theme.nav, font_size: 20, translate: {150, 120})
         |> text("Welcome!", fill: @theme.nav, font_size: 26, translate: {150, 200})
         |> text(@tips, fill: @theme.nav, font_size: 20, translate: {150, 220})
         |> Nav.add_to_graph(__MODULE__)



  def init(_, opts) do
    :observer.start
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
