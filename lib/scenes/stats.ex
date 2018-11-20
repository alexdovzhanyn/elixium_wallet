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
         |> line({{924,0}, {924, 640}},  stroke: {4, @theme.jade})
         |> line({{100,300}, {650, 300}},  stroke: {4, @theme.jade})
         |> line({{100,450}, {650, 450}},  stroke: {4, @theme.jade})
         |> line({{375,300}, {375, 450}},  stroke: {4, @theme.jade})
         |> text("LATENCY", id: :latency, font_size: 16, translate: {945, 90})
         |> circle(10, id: :lat1_stat,  fill: :green, stroke: {2, :white}, t: {940, 120})
         |> text("90ms", id: :lat1, font_size: 16, translate: {960, 120})
         |> circle(10, id: :lat2_stat, fill: :clear, stroke: {2, :white}, t: {940, 150})
         |> text("0ms", id: :lat2, font_size: 16, translate: {960, 150})
         |> circle(10, id: :lat3_stat, fill: :clear, stroke: {2, :white}, t: {940, 180})
         |> text("0ms", id: :lat3, font_size: 16, translate: {960, 180})
         |> circle(10, id: :lat4_stat, fill: :clear, stroke: {2, :white}, t: {940, 210})
         |> text("0ms", id: :lat4, font_size: 16, translate: {960, 210})
         |> circle(10, id: :lat5_stat, fill: :clear, stroke: {2, :white}, t: {940, 240})
         |> text("0ms", id: :lat5, font_size: 16, translate: {960, 240})
         |> circle(10, id: :lat6_stat, fill: :clear, stroke: {2, :white}, t: {940, 270})
         |> text("0ms", id: :lat6, font_size: 16, translate: {960, 270})
         |> circle(10, id: :lat7_stat, fill: :clear, stroke: {2, :white}, t: {940, 300})
         |> text("0ms", id: :lat7, font_size: 16, translate: {960, 300})
         |> circle(10, id: :lat8_stat, fill: :clear, stroke: {2, :white}, t: {940, 330})
         |> text("0ms", id: :lat8, font_size: 16, translate: {960, 330})
         |> circle(10, id: :lat9_stat, fill: :clear, stroke: {2, :white}, t: {940, 360})
         |> text("0ms", id: :lat9, font_size: 16, translate: {960, 360})
         |> circle(10, id: :lat10_stat, fill: :clear, stroke: {2, :white}, t: {940, 390})
         |> text("0ms", id: :lat10, font_size: 16, translate: {960, 390})
         |> text("STATISTICS", id: :title, font_size: 26, translate: {450, 25})
         |> circle(90, fill: :blue, stroke: {0, :clear}, t: {240, 150})
         |> sector({90, -0.3, -0.8}, fill: :green, translate: {240, 150})
         |> text("Registered Peers", id: :title, font_size: 26, translate: {350, 130})
         |> text("0", id: :reg_peers, font_size: 26, translate: {375, 150})
         |> text("Connected Peers", id: :title, font_size: 26, translate: {350, 180})
         |> text("0", id: :con_peers, font_size: 26, translate: {375, 200})
         |> text("AVERAGE PING: ", id: :av_ping, font_size: 20, translate: {120, 360})
         |> text("90ms", id: :av_input, font_size: 20, translate: {250, 360})
         |> text("HIGHEST PING: ", id: :hi_ping, font_size: 20, translate: {120, 390})
         |> text("90ms", id: :hi_input, font_size: 20, translate: {250, 390})
         |> text("LOWEST PING: ", id: :lo_ping, font_size: 20, translate: {120, 420})
         |> text("90ms", id: :lo_input, font_size: 20, translate: {250, 420})
         |> text("CURRENT DIFFICULTY: ", id: :difficulty, font_size: 20, translate: {120, 500})
         |> text("3000", id: :diff_input, font_size: 20, translate: {300, 500})
         |> text("CURRENT BLOCK: ", id: :block, font_size: 20, translate: {120, 530})
         |> text("213", id: :block_input, font_size: 20, translate: {300, 530})
         |> button("Back", id: :btn_back, width: 80, height: 46, theme: :dark, translate: {10, 80})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    push_graph(@graph)
    update(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  def filter_event({:click, :btn_back}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Home, nil})
    {:continue, {:click, :btn_back}, state}
  end



  defp update(graph) do
    latency_table = Scenic.Cache.get!("latency_global")
    graph = graph
      |> Graph.modify(:reg_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("registered_peers"))))
      |> Graph.modify(:con_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("connected_peers"))))
      |> Graph.modify(:av_input, &text(&1, Float.to_string(elem(Scenic.Cache.get!("latency"), 0))))
      |> Graph.modify(:hi_input, &text(&1, Float.to_string(elem(Scenic.Cache.get!("latency"), 2))))
      |> Graph.modify(:lo_input, &text(&1, Float.to_string(elem(Scenic.Cache.get!("latency"), 1))))
      |> Graph.modify(:block_input, &text(&1, Integer.to_string(elem(Scenic.Cache.get!("block_info"), 0))))
      |> Graph.modify(:diff_input, &text(&1, Float.to_string(elem(Scenic.Cache.get!("block_info"), 1))))
      |> Graph.modify(:lat1, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 0))/1)<>"ms"))
      |> Graph.modify(:lat1_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 0))))
      |> Graph.modify(:lat2, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 1))/1)<>"ms"))
      |> Graph.modify(:lat2_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 1))))
      |> Graph.modify(:lat3, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 2))/1)<>"ms"))
      |> Graph.modify(:lat3_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 2))))
      |> Graph.modify(:lat4, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 3))/1)<>"ms"))
      |> Graph.modify(:lat4_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 3))))
      |> Graph.modify(:lat5, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 4))/1)<>"ms"))
      |> Graph.modify(:lat5_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 4))))
      |> Graph.modify(:lat6, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 5))/1)<>"ms"))
      |> Graph.modify(:lat6_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 5))))
      |> Graph.modify(:lat7, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 6))/1)<>"ms"))
      |> Graph.modify(:lat7_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 6))))
      |> Graph.modify(:lat8, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 7))/1)<>"ms"))
      |> Graph.modify(:lat8_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 7))))
      |> Graph.modify(:lat9, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 8))/1)<>"ms"))
      |> Graph.modify(:lat9_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 8))))
      |> Graph.modify(:lat10, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 9))/1)<>"ms"))
      |> Graph.modify(:lat10_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 9))))
      |> push_graph()
  end

  defp get_times({id, time}), do: time
  defp get_status({id, time}) when time == 999, do: :red
  defp get_status({id, time}) when time !== 999, do: :green




  

end
