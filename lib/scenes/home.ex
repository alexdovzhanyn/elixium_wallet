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

  @parrot_width 480
  @parrot_height 270

  @body_offset 80

  @line {{0, 0}, {60, 60}}

  @notes """
    \"Primitives\" shows the various primitives available in Scenic.
    It also shows a sampling of the styles you can apply to them.
  """

  @graph Graph.build(font: :roboto, font_size: 24)
          |> rect(
            {@parrot_width, @parrot_height},
            id: :parrot,
            fill: {:image, {@parrot_hash, 50}},
            translate: {135, 150}
            )
         |> rect({300, 75}, fill: {10,10,10}, translate: {300, 100})
         |> text("Current Balance", text_align: :center, translate: {200, 150})
         |> button("Stats", id: :btn_stats, width: 80, height: 46, fill: {:image, {@parrot_hash, 50}}, translate: {10, 200})
         |> button("Balance", id: :btn_balance, width: 80, height: 46, theme: :dark, translate: {10, 275})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

        position = {
          vp_width / 2 - @parrot_width / 2,
          vp_height / 2 - @parrot_height / 2
        }
        Scenic.Cache.File.load(@parrot_path, @parrot_hash)

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
