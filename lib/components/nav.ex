defmodule ElixWallet.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components


  # import IEx

  @height 50
  @theme Application.get_env(:elix_wallet, :theme)
  @event_str "Event received: "

  # --------------------------------------------------------
  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(current_scene, opts) do
    styles = opts[:styles] || %{}
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, height}}} =
      opts[:viewport]
      |> ViewPort.info()

      col = vp_width / 6

      graph =
        Graph.build(styles: styles, font_size: 20)
        |> rect({vp_width, @height}, fill: @theme.nav)
        |> rect({vp_width, 10}, fill: @theme.shadow, translate: {0, 45})
        |> button("Send", id: :btn_send, width: 95, height: 46, theme: :dark, translate: {320, 5})
        |> button("Home", id: :btn_home, width: 95, height: 46, translate: {220, 5}, fill: {255,255,255})
        |> button("Receive", id: :btn_receive, width: 95, height: 46, theme: :dark, translate: {420, 5})
        |> button("Key Settings", id: :btn_key, width: 95, height: 46, theme: :dark, translate: {520, 5})

        |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end



  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state)
      when is_atom(scene) do
        IO.puts "Chaning"
    ViewPort.set_root(vp, {scene, nil})
    {:stop, state}
  end

  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state) do
    IO.puts "Changin Alt n2"
    ViewPort.set_root(vp, scene)
    {:stop, state}
  end

  def filter_event({:click, :btn_send}, _, %{viewport: vp} = state) do
    IO.puts "Button Clicked Send"
    ViewPort.set_root(vp, {ElixWallet.Scene.Send, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_home}, _, %{viewport: vp} = state) do
    IO.puts "Button Clicked Home"
    ViewPort.set_root(vp, {ElixWallet.Scene.Home, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_key}, _, %{viewport: vp} = state) do
    IO.puts "Button Clicked Keys"
    ViewPort.set_root(vp, {ElixWallet.Scene.Keys, nil})
    {:stop, state}
  end

  #def filter_event({:click, :btn_receive}, _, graph) do
  #  IO.puts "Button Clicked receive"
  #  # No need to return anything. Already crashed.
  #  :continue
  #end

  #def filter_event({:click, :btn_key}, _, graph) do
  #  IO.puts "Button Clicked Key"
  #  # No need to return anything. Already crashed.
  #  :continue
#  end

  # display the received message
  #def filter_event(event, _, graph) do
  #  graph =
  #    graph
  #    |> Graph.modify(:event, &text(&1, @event_str <> inspect(event)))
  #    |> push_graph()

  #  {:continue, event, graph}
  #end
end
