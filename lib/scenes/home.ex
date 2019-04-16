defmodule ElixiumWallet.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort

  alias ElixiumWallet.Component.Nav
  alias ElixiumWallet.Component.Notes
  alias ElixiumWallet.Utilities

  @theme Application.get_env(:elixium_wallet, :theme)
  @balance_path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/xex_logo_72.png")
  @balance_hash Scenic.Cache.Hash.file!( @balance_path, :sha )

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

  @path :code.priv_dir(:elixium_wallet)
               |> Path.join("/static/images/Logo.png")
  @hash Scenic.Cache.Hash.file!( @path, :sha )
  


      @graph Graph.build(font: :roboto, font_size: 24, clear_color: @theme.nav)
         
         |> rrect({320, 220, 25}, fill: @theme.jade, translate: {220, 100})
         |> rrect({320, 220, 25}, fill: @theme.jade, translate: {600, 100})
         |> text("Elixium News", fill: @theme.light_text, font_size: 26, translate: {200, 500})
         |> text(@news_feed, fill: @theme.light_text, font_size: 20, translate: {200, 520})
         |> text("Welcome!", fill: @theme.light_text, font_size: 26, translate: {200, 400})
         |> text(@tips, fill: @theme.light_text, font_size: 20, translate: {200, 420})
         |> text("Balance: 0.0", fill: @theme.light_text, font_size: 38, translate: {240, 220})
         |> text("USD: 0.0", fill: @theme.light_text, font_size: 24, translate: {240, 260})
         |> text("Status: Connected", fill: @theme.light_text, font_size: 38, translate: {620, 220})
         |> text("Connections: 0", fill: @theme.light_text, font_size: 24, translate: {620, 260})
         |> text("Height: 0", fill: @theme.light_text, font_size: 24, translate: {780, 260})
         |> text_field("Sample Text", id: :text_id, translate: {250,20})
         |> Nav.add_to_graph(__MODULE__)
         #|> rect({10, 30}, fill: @theme.nav, translate: {130, 110})
         #|> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 110})
         #|> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 140})



  def init(_, opts) do
    Scenic.Cache.File.load(@path, @hash)
    Scenic.Cache.File.load(@balance_path, @balance_hash)


    push_graph(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end


  






  def filter_event({:click, :btn_balance}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Balance, nil})
    {:continue, {:click, :btn_balance}, state}
  end

  def filter_event({:click, :btn_stats}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {ElixiumWallet.Scene.Stats, nil})
    {:continue, {:click, :btn_stats}, state}
  end


end
