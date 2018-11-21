defmodule ElixWallet.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort

  alias ElixWallet.Component.Nav


  @parrot_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/Logo.png")
  @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )
  @stats_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/bar-chart-6x.png")
  @stats_hash Scenic.Cache.Hash.file!( @stats_path, :sha )
  @balance_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/random-6x.png")
  @balance_hash Scenic.Cache.Hash.file!( @balance_path, :sha )

  @theme Application.get_env(:elix_wallet, :theme)
  @parrot_width 480
  @parrot_height 270

  @body_offset 80

  @line {{0, 0}, {60, 60}}

  @notes """
    \"Primitives\" shows the various primitives available in Scenic.
    It also shows a sampling of the styles you can apply to them.
  """

  @graph Graph.build(font: :roboto, font_size: 24)

         |> rect({80, 600}, translate: {0, 45}, fill: @theme.nav)
         |> rect({300, 75}, fill: {10,10,10}, translate: {300, 100})
         |> text("Current Balance", text_align: :center, translate: {200, 150})
         |> button("", id: :btn_stats, width: 50, height: 46, fill: :blue, translate: {200, 200})
         |> button("", id: :btn_balance, width: 50, height: 46, fill: :blue, translate: {200, 275})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

        position = {
          vp_width / 2 - @parrot_width / 2,
          vp_height / 2 - @parrot_height / 2
        }

        Scenic.Cache.File.load(@parrot_path, @parrot_hash)
        Scenic.Cache.File.load(@stats_path, @stats_hash)
        Scenic.Cache.File.load(@balance_path, @balance_hash)
        
        push_graph(@graph)

    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
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
