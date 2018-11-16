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
  @height 50
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
         |> line({{650,0}, {650, 600}},  stroke: {4, @theme.shadow})
         |> text("LATENCY", id: :latency, font_size: 16, translate: {700, 90})
         |> circle(10, fill: :green, stroke: {2, :white}, t: {675, 120})
         |> text("90ms", id: :lat1, font_size: 16, translate: {710, 120})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 150})
         |> text("0ms", id: :lat1, font_size: 16, translate: {710, 150})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 180})
         |> text("0ms", id: :lat2, font_size: 16, translate: {710, 180})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 210})
         |> text("0ms", id: :lat3, font_size: 16, translate: {710, 210})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 240})
         |> text("0ms", id: :lat4, font_size: 16, translate: {710, 240})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 270})
         |> text("0ms", id: :lat5, font_size: 16, translate: {710, 270})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 300})
         |> text("0ms", id: :lat6, font_size: 16, translate: {710, 300})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 330})
         |> text("0ms", id: :lat7, font_size: 16, translate: {710, 330})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 360})
         |> text("0ms", id: :lat8, font_size: 16, translate: {710, 360})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 390})
         |> text("0ms", id: :lat9, font_size: 16, translate: {710, 390})
         |> circle(10, fill: :clear, stroke: {2, :white}, t: {675, 420})
         |> text("0ms", id: :lat10, font_size: 16, translate: {710, 420})
         |> text("STATISTICS", id: :title, font_size: 26, translate: {275, 100})
         |> circle(90, fill: :blue, stroke: {0, :clear}, t: {250, 250})
         |> sector({90, -0.3, -0.8}, fill: :green, translate: {250, 250})
         |> text("Registered Peers", id: :title, font_size: 26, translate: {350, 200})
         |> text("0", id: :reg_peers, font_size: 26, translate: {375, 220})
         |> text("Connected Peers", id: :title, font_size: 26, translate: {350, 300})
         |> text("0", id: :con_peers, font_size: 26, translate: {375, 320})
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
    connected_peers = Elixium.P2P.Peer.connected_handlers
    registered_peers = Elixium.P2P.Peer.fetch_peers_from_registry(31013) |> IO.inspect

    connected_peers |> Enum.map(fn peer -> get_ping_time(peer) end) |> IO.inspect
    case registered_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, Enum.count(registered_peers)})
    end
    case connected_peers do
      [] -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      :not_found -> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
      _-> :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, Enum.count(connected_peers)})
    end
  end

  defp get_ping_time(pid) do
    start = :erlang.timestamp()
    with :pang <- :net_adm.ping(:erlang.node(pid)) do
      ping = :timer.now_diff(:erlang.timestamp(), start)
      {:ok, {:erlang.node(pid), ping/1000}}
    else
      false ->
        ping = :timer.now_diff(:erlang.timestamp(), start)
      {:error, {node(pid), ping/1000}}
    end
  end

  defp update(graph) do
    graph = graph
      |> Graph.modify(:reg_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("registered_peers"))))
      |> Graph.modify(:con_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("connected_peers"))))
      |> push_graph()
  end


end
