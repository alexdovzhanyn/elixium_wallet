defmodule ElixWallet.Scene.Balance do
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
         |> rect({300, 75}, fill: {20,20,20}, translate: {300, 200})
         |> text("BALANCE", id: :title, font_size: 26, translate: {275, 100})
         |> button("Back", id: :btn_back, width: 80, height: 46, theme: :dark, translate: {10, 80})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]

    # calculate the transform that centers the parrot in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    #Scenic.Cache.File.load(@parrot_path, @parrot_hash)


        position = {
          vp_width / 2 - @parrot_width / 2,
          vp_height / 2 - @parrot_height / 2
        }

        IO.inspect position

        # load the parrot texture into the cache
        Scenic.Cache.File.load(@parrot_path, @parrot_hash)

        # move the parrot into the right location
        push_graph(@graph)
  #  push_graph(@graph)

    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  def filter_event({:click, :btn_back}, _, %{viewport: vp} = state) do
    IO.puts "Anbout to fetch graph"
    ViewPort.set_root(vp, {ElixWallet.Scene.Home, nil})
    {:continue, {:click, :btn_back}, state}
  end


end
