defmodule ElixWallet.Scene.Stats do
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
         |> text("STATISTICS", id: :title, font_size: 26, translate: {275, 100})
         |> text("Registered Peers", id: :title, font_size: 26, translate: {275, 200})
         |> text("0", id: :reg_peers, font_size: 26, translate: {300, 220})
         |> button("Back", id: :btn_back, width: 80, height: 46, theme: :dark, translate: {10, 80})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    get_stats()
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    push_graph(@graph)
    update(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  def filter_event({:click, :btn_back}, _, %{viewport: vp} = state) do
    IO.puts "Anbout to fetch graph"
    ViewPort.set_root(vp, {ElixWallet.Scene.Home, nil})
    {:continue, {:click, :btn_back}, state}
  end

  defp get_stats() do
    Elixium.P2P.Peer.connected_peers |> IO.inspect
    registry_peers = Elixium.P2P.Peer.fetch_peers_from_registry(31013) |> Enum.count
    :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, registry_peers})
  end

  defp update(graph) do
    graph = graph |> Graph.modify(:reg_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("registered_peers")))) |> push_graph()
  end


end
