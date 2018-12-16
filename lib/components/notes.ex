defmodule ElixiumWallet.Component.Notes do
  use Scenic.Component
  require Logger

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
  @lock_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/lock_icon.png")
  @lock_hash Scenic.Cache.Hash.file!( @lock_path, :sha )

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(notes, opts) do
    Scenic.Cache.File.load(@net_path, @net_hash)
    Scenic.Cache.File.load(@conn_path, @conn_hash)
    Scenic.Cache.File.load(@balance_path, @balance_hash)
    Scenic.Cache.File.load(@lock_path, @lock_hash)
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({vp_width, 30}, font_blur: 0.5, fill: {:linear, {0, 0, 0, 20, {50,50,50}, {8,8,8}}}, translate: {0, 8})
      |> rect({vp_width, 30}, fill: {:linear, {0, 0, 0, 20, {50,50,50}, {25,25,25}}})
      |> rect({vp_width, 30}, font_blur: 0.5, fill: {:linear, {0, 0, 0, 20, {8,8,8}, {50,50,50}}}, translate: {0, 622})
      |> rect({vp_width, 30}, fill: {:linear, {0, 15, 0, 0, {25,25,25}, {50,50,50}}}, translate: {0, 620})
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
      ##|> rect(
      #  {24, 24},
      #  fill: {:image, {@lock_hash, 155}},
      #  translate: {860, 2}
      #)
      |> rect(
        {24, 24},
        fill: {:image, {@balance_hash, 155}},
        translate: {180, 2}
      )
      |> text(Integer.to_string(Utilities.get_from_cache(:peer_info, "connected_peers")), font_size: 16, translate: {235, 635})
      |> text("/", font_size: 16, translate: {245, 635})
      |> text(Integer.to_string(Utilities.get_from_cache(:peer_info, "registered_peers")), font_size: 16, translate: {255, 635})
      |> text("Waiting..", id: :status, font_size: 16, translate: {455, 635})
      |> text(notes, translate: {@indent, @font_size * 1})
      |> text("version 0.1.6 Alpha", font_size: 16, translate: {850, 635})
      |> push_graph()

      {:ok, timer} = :timer.send_interval(30, :animate)

      Utilities.store_in_cache(:user_info, "core_info", self())
      state = %{
        timer: timer,
        graph: graph,
        alpha: 0,
        id: :notes,
      }

    {:ok, state}
  end

  def handle_info(:animate, %{timer: timer, alpha: a} = state) when a >= 256 do
    :timer.cancel(timer)
    Process.send_after(self(), :finish, 200)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:update, item}, state) do
    graph =
      state.graph
      |> Graph.modify(:status, &text(&1, item))
      |> push_graph()

   {:noreply, state}
 end

  def handle_info(:finish, state) do
    {:ok, timer} = :timer.send_interval(30, :animate)

    state = Map.put(state, :timer, timer)
    {:noreply, state}
  end

  def handle_info(:animate, %{alpha: alpha, graph: graph} = state) do


    {:noreply, %{state | graph: graph, alpha: alpha + 2}}
  end




end
