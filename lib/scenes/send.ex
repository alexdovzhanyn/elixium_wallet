defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    import Scenic.Primitives

    alias ElixWallet.Component.Nav


    @bird_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
    @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )

    @bird_width 100
    @bird_height 128

    @body_offset 80

    @line {{0, 0}, {60, 60}}

    @notes """
      \"Primitives\" shows the various primitives available in Scenic.
      It also shows a sampling of the styles you can apply to them.
    """

    @graph Graph.build(font: :roboto, font_size: 24)
           |> text("SEND", id: :small_text, font_size: 26, translate: {275, 100})

           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)


    def init(_, _opts) do
      # load the parrot texture into the cache
      Scenic.Cache.File.load(@bird_path, @bird_hash)

      push_graph(@graph)

      {:ok, @graph}
    end

    




  end
