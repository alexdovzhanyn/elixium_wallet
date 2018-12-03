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


    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
               |> text("KEY CONFIGURATION", id: :small_text, font_size: 26, translate: {425, 50})
               |> button("Import", id: :btn_import, width: 80, height: 46, theme: :dark, translate: {300, 200})

               |> button("Export", id: :btn_export, width: 80, height: 46, theme: :dark, translate: {550, 200})
               |> Nav.add_to_graph(__MODULE__)


    def init(_, opts) do

      graph = push_graph(@graph)
      {:ok, %{graph: graph, viewport: opts[:viewport]}}
    end

  



  end
