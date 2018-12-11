defmodule ElixiumWallet.Component.Notes do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias ElixiumWallet.Utilities


  import Scenic.Primitives

  @height 30
  @font_size 20
  @indent 210
  @theme Application.get_env(:elixium_wallet, :theme)
  @net_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/network.png")
  @net_hash Scenic.Cache.Hash.file!( @net_path, :sha )
  @conn_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/connect.png")
  @conn_hash Scenic.Cache.Hash.file!( @conn_path, :sha )
  @balance_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/xexbalancemaster.png")
  @balance_hash Scenic.Cache.Hash.file!( @balance_path, :sha )

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(notes, opts) do
    Scenic.Cache.File.load(@net_path, @net_hash)
    Scenic.Cache.File.load(@conn_path, @conn_hash)
    Scenic.Cache.File.load(@balance_path, @balance_hash)
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({vp_width, @height}, fill: {:linear, {0, 50, 0, 0, {25,25,25}, {50,50,50}}})
      |> rect({vp_width, 30}, fill: {:linear, {0, 50, 0, 0, {25,25,25}, {50,50,50}}}, translate: {0, 620})
      |> circle(6, stroke: {0, :clear}, fill: Utilities.update_connection_status(), translate: {200, 630})
      |> rect(
        {12, 12},
        fill: {:image, {@net_hash, 200}},
        translate: {220, 624}
      )
      |> rect(
        {12, 12},
        fill: {:image, {@conn_hash, 255}},
        translate: {180, 624}
      )
      |> rect(
        {24, 24},
        fill: {:image, {@balance_hash, 155}},
        translate: {180, 2}
      )
      |> text(Integer.to_string(Utilities.get_from_cache(:peer_info, "connected_peers")), font_size: 16, translate: {235, 635})
      |> text("/", font_size: 16, translate: {245, 635})
      |> text(Integer.to_string(Utilities.get_from_cache(:peer_info, "registered_peers")), font_size: 16, translate: {255, 635})
      |> text("Blocks Sync'd: 184/254", font_size: 16, translate: {455, 635})
      |> text(notes, translate: {@indent, @font_size * 1})
      |> text("version 0.1.4 Alpha", font_size: 16, translate: {850, 635})
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end
