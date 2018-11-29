defmodule ElixWallet.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  alias Scenic.ViewPort

  alias ElixWallet.Component.Nav

  @theme Application.get_env(:elix_wallet, :theme)

  @tips """
        Welcome to Elixium Wallet!
        Here you can Send, Receive your XEX, generate new keys
        and check the status of the Elixium Network
        """

@news_feed """
    Fast transactions, #anonymized network, and #Javascript contracts -- the perfect trio.
    We're building something you won't want to miss out on, so join us on the journey!
    http://t.me/elixiumnetwork  #blockchain #Elixium
  """

  @graph Graph.build(font: :roboto, font_size: 24)
         |> text("Elixium News", fill: @theme.nav, font_size: 26, translate: {150, 100})
         |> text(@news_feed, fill: @theme.nav, font_size: 20, translate: {150, 120})
         |> text("Welcome!", fill: @theme.nav, font_size: 26, translate: {150, 200})
         |> text(@tips, fill: @theme.nav, font_size: 20, translate: {150, 220})
         |> Nav.add_to_graph(__MODULE__)



  def init(_, opts) do
    push_graph(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  def filter_event({:click, :btn_balance}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Balance, nil})
    {:continue, {:click, :btn_balance}, state}
  end

  def filter_event({:click, :btn_stats}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixWallet.Scene.Stats, nil})
    {:continue, {:click, :btn_stats}, state}
  end


end
