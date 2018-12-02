defmodule ElixWallet.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias ElixWallet.Utilities
  alias ElixWallet.Component.Notes

  import Scenic.Primitives
  import Scenic.Components


  # import IEx

  @height 50
  @theme Application.get_env(:elix_wallet, :theme)

  @font_path :code.priv_dir(:elix_wallet)
             |> Path.join("/static/fonts/museo.ttf")
  @font_hash Scenic.Cache.Hash.file!(@font_path, :sha )
  @logo_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/logoalt.png")
  @logo_hash Scenic.Cache.Hash.file!(@logo_path, :sha )
  @history_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/history.png")
  @history_hash Scenic.Cache.Hash.file!(@history_path, :sha )

  @stats_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/stats3.png")
  @stats_hash Scenic.Cache.Hash.file!(@stats_path, :sha )
  @home_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/home.png")
  @home_hash Scenic.Cache.Hash.file!(@home_path, :sha )
  @send_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/send.png")
  @send_hash Scenic.Cache.Hash.file!(@send_path, :sha )
  @receive_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/target.png")
  @receive_hash Scenic.Cache.Hash.file!(@receive_path, :sha )
  @settings_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/key.png")
  @settings_hash Scenic.Cache.Hash.file!(@settings_path, :sha )

  @notes "Balance: 150901.9 XEX"

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

      init_cache_files
      balance = get_balance()
      graph =
        Graph.build(styles: styles, font_size: 20)
        |> Notes.add_to_graph("Balance: " <> balance)
        |> rect({130, height}, fill: {:linear, {0, 0, 130, 0, @theme.darknav, @theme.nav}}, translate: {0,0})
        |> rect({200, 200}, fill: {:image, {@logo_hash, 200}}, translate: {-35, 0})
        |> line({{130,0}, {130, 640}},  stroke: {6, @theme.jade})
        |> icon("Stats   ", id: :btn_stats, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 400}, img: @stats_hash)
        |> icon("Send", id: :btn_send, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 175}, img: @send_hash)
        |> icon("Home", id: :btn_home, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 100}, img: @home_hash)
        |> icon("Receive", id: :btn_receive, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 250}, img: @receive_hash)
        |> icon("Keys", id: :btn_key, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 475}, img: @settings_hash)
        |> icon("History", id: :btn_history, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 325}, img: @history_hash)
        |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end

  defp init_cache_files do
    Scenic.Cache.File.load(@logo_path, @logo_hash)
    Scenic.Cache.File.load(@history_path, @history_hash)
    Scenic.Cache.File.load(@home_path, @home_hash)
    Scenic.Cache.File.load(@send_path, @send_hash)
    Scenic.Cache.File.load(@stats_path, @stats_hash)
    Scenic.Cache.File.load(@receive_path, @receive_hash)
    Scenic.Cache.File.load(@settings_path, @settings_hash)
    Scenic.Cache.File.load(@font_path, @font_hash)
  end

  defp get_balance do
    Float.to_string(Utilities.get_from_cache(:user_info, "current_balance"))
  end

  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state)
      when is_atom(scene) do
    ViewPort.set_root(vp, {scene, nil})
    {:stop, state}
  end

  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, scene)
    {:stop, state}
  end

  #def filter_event(event, _,state), do: {:continue, event, state}


  def filter_event({:click, :btn_stats}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Stats, styles: %{fill: :blue}})
    #{:continue, {:click, :btn_stats}, state}
    {:stop, state}
  end

  def filter_event({:click, :btn_history}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.TransactionHistory, styles: %{fill: :blue}})
    #{:continue, {:click, :btn_history}, state}
    {:stop, state}
  end

  def filter_event({:click, :btn_send}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Send, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_home}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Home, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_key}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Keys, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_receive}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Recieve, nil})
    {:stop, state}
  end

end
