defmodule ElixiumWallet.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias ElixiumWallet.Utilities
  alias ElixiumWallet.Component.Notes

  import Scenic.Primitives
  import Scenic.Components


  # import IEx

  @height 50
  @theme Application.get_env(:elixium_wallet, :theme)

  @font_path :code.priv_dir(:elixium_wallet)
             |> Path.join("/static/fonts/museo.ttf")
  @font_hash Scenic.Cache.Hash.file!(@font_path, :sha )
  @logo_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/logoalt.png")
  @logo_hash Scenic.Cache.Hash.file!(@logo_path, :sha )
  @history_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/history.png")
  @history_hash Scenic.Cache.Hash.file!(@history_path, :sha )

  @stats_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/stats3.png")
  @stats_hash Scenic.Cache.Hash.file!(@stats_path, :sha )
  @home_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/home.png")
  @home_hash Scenic.Cache.Hash.file!(@home_path, :sha )
  @send_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/send.png")
  @send_hash Scenic.Cache.Hash.file!(@send_path, :sha )
  @receive_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/target.png")
  @receive_hash Scenic.Cache.Hash.file!(@receive_path, :sha )
  @settings_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/key.png")
  @settings_hash Scenic.Cache.Hash.file!(@settings_path, :sha )
  @import_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/import_k.png")
  @import_hash Scenic.Cache.Hash.file!(@import_path, :sha )
  @export_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/export_k.png")
  @export_hash Scenic.Cache.Hash.file!(@export_path, :sha )
  @lock_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/lock.png")
  @lock_hash Scenic.Cache.Hash.file!(@lock_path, :sha )
  @i_col {40, 40, 40}
  @outline {55,55,55}
  @toggle_green {0, 255, 0}
  @toggle_off {255, 0, 0}

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
        |> Notes.add_to_graph(balance, id: :notes)
        |> rect({10, height}, fill: {:linear, {0, 0, 5, 0, @theme.darknav, @theme.nav}}, translate: {132,0})
        #|> rect({10, height}, fill: {:linear, {0, 0, 130, 0, {25,25,25}, {255,255,255}}}, translate: {130,0})
        |> rect({130, height}, fill: {:linear, {0, 0, 110, 0, @theme.darknav, @theme.nav}}, translate: {0,0})

        |> rect({200, 200}, fill: {:image, {@logo_hash, 200}}, translate: {-35, 0})
        |> icon("Home", id: :btn_home, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 200}, img: @home_hash)
        |> icon("Stats   ", id: :btn_stats, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 260}, img: @stats_hash)
        |> icon("Receive", id: :btn_receive, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 320}, img: @receive_hash)
        |> icon("History", id: :btn_history, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 380}, img: @history_hash)
        |> icon("Send", id: :btn_send, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 440}, img: @send_hash)
        |> icon("Import", id: :btn_import, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 500}, img: @import_hash)
        |> icon("Export", id: :btn_export, font_blur: 0.1, alignment: :right, width: 48, height: 48, translate: {10, 560}, img: @export_hash)
#Toggle ON
        #|> circle(11, id: :slide1, fill: @toggle_off, stroke: {1, @outline}, t: {900, 15})
        #|> circle(11, id: :slide2, fill: @toggle_off, stroke: {1, @outline}, t: {940, 15})
        #|> rect({40, 22}, id: :slide3, fill: @toggle_off, stroke: {0, @outline}, translate: {900,4})
#Button Slide
        #|> icon("", id: :btn_lock, font_blur: 0.1, width: 24, height: 24, translate: {888, 4}, img: @lock_hash)
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
    Scenic.Cache.File.load(@import_path, @import_hash)
    Scenic.Cache.File.load(@export_path, @export_hash)
    Scenic.Cache.File.load(@lock_path, @lock_hash)
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

  def filter_event({:click, :btn_lock}, _, state) do
    {x, y} = Graph.get!(state.graph, :btn_lock).transforms.translate

    state =
    if x > 900 do
      animate(%{alpha: 0, state: state}, :lock)
    else
      animate(%{alpha: 0, state: state}, :unlock)
    end


    {:stop, state}
  end

  def animate(%{alpha: a, state: state}, type) when a >= 40 do
    state
  end

  def animate(%{alpha: a, state: state}, :unlock) do
    {x, y} = Graph.get!(state.graph, :btn_lock).transforms.translate

    graph =
      state.graph
      |> Graph.modify(:btn_lock, &update_opts(&1, translate: {x + 2, y}))
      |> Graph.modify(:btn_lock, &update_opts(&1, img: @lock_hash))
      |> Graph.modify(:slide1, &update_opts(&1, fill: {0, 255, 0}))
      |> Graph.modify(:slide2, &update_opts(&1, fill: {0, 255, 0}))
      |> Graph.modify(:slide3, &update_opts(&1, fill: {0, 255, 0}))
      |> push_graph()

      state = Map.put(state, :graph, graph)

    animate(%{alpha: a + 2, state: state}, :unlock)
  end

  def animate(%{alpha: a, state: state}, :lock) do
    {x, y} = Graph.get!(state.graph, :btn_lock).transforms.translate

    graph =
      state.graph
      |> Graph.modify(:btn_lock, &update_opts(&1, translate: {x - 2, y}))
      |> Graph.modify(:btn_lock, &update_opts(&1, img: @lock_hash))
      |> Graph.modify(:slide1, &update_opts(&1, fill: {255, 0, 0}))
      |> Graph.modify(:slide2, &update_opts(&1, fill: {255, 0, 0}))
      |> Graph.modify(:slide3, &update_opts(&1, fill: {255, 0, 0}))
      |> push_graph()

      state = Map.put(state, :graph, graph)

    animate(%{alpha: a + 2, state: state}, :lock)
  end

  def filter_event({:click, :btn_stats}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Stats, styles: %{fill: :blue}})
    #{:continue, {:click, :btn_stats}, state}
    {:stop, state}
  end

  def filter_event({:click, :btn_history}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.TransactionHistory, styles: %{fill: :blue}})
    #{:continue, {:click, :btn_history}, state}
    {:stop, state}
  end

  def filter_event({:click, :btn_send}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Send, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_home}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Home, nil})

    {:stop, state}
  end

  def filter_event({:click, :btn_key}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Keys, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_receive}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Recieve, nil})

  end

  def filter_event({:click, :btn_import}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.ImportKey, nil})
    {:stop, state}
  end

  def filter_event({:click, :btn_export}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.BackupKey, nil})
    {:stop, state}
  end


end
