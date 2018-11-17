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

  @home_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/home-6x.png")
  @home_hash Scenic.Cache.Hash.file!(@home_path, :sha )
  @send_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/account-logout-6x.png")
  @send_hash Scenic.Cache.Hash.file!(@send_path, :sha )
  @receive_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/account-login-6x.png")
  @receive_hash Scenic.Cache.Hash.file!(@receive_path, :sha )
  @settings_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cog-6x.png")
  @settings_hash Scenic.Cache.Hash.file!(@settings_path, :sha )


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
      Scenic.Cache.File.load(@home_path, @home_hash)
      Scenic.Cache.File.load(@send_path, @send_hash)
      Scenic.Cache.File.load(@receive_path, @receive_hash)
      Scenic.Cache.File.load(@settings_path, @settings_hash)

      col = vp_width / 6

      graph =
        Graph.build(styles: styles, font_size: 20)
        
        |> rect({vp_width, @height}, fill: @theme.darknav)
        |> rect({vp_width, 10}, fill: @theme.nav, translate: {0, 45})
        |> icon("", id: :btn_send, width: 50, height: 46, translate: {320, 5}, img: @send_hash)
        |> icon("", id: :btn_home, width: 50, height: 46, translate: {220, 5}, img: @home_hash)
        |> icon("", id: :btn_receive, width: 50, height: 46, translate: {420, 5}, img: @receive_hash)
        |> icon("", id: :btn_key, width: 50, height: 46, translate: {520, 5}, img: @settings_hash)

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

  def filter_event({:click, :btn_receive}, _, %{viewport: vp} = state) do
    IO.puts "Button Clicked receive"
    # No need to return anything. Already crashed.
    ViewPort.set_root(vp, {ElixWallet.Scene.Recieve, nil})
    {:stop, state}
  end



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
