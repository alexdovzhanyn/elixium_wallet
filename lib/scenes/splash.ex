defmodule ElixWallet.Scene.Splash do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  alias Scenic.ViewPort

  # import Scenic.Components

  @note """
    Elixium Desktop Wallet
  """

  @parrot_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/Logo.png")
  @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )

  @parrot_width 480
  @parrot_height 270

  @graph Graph.build()
         |> rect(
           {@parrot_width, @parrot_height},
           id: :parrot,
           fill: {:image, {@parrot_hash, 0}}
         )

  @animate_ms 30
  @finish_delay_ms 1000


  #@graph Graph.build(font: :roboto, font_size: 24)
  #|> text(@note, translate: {20, 60})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  ##def init(_, _) do
  ##  push_graph( @graph )
  ##  {:ok, @graph}
  ##end

  def init(first_scene, opts) do
    viewport = opts[:viewport]

    # calculate the transform that centers the parrot in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    position = {
      vp_width / 2 - @parrot_width / 2,
      vp_height / 2 - @parrot_height / 2
    }

    # load the parrot texture into the cache
    Scenic.Cache.File.load(@parrot_path, @parrot_hash)

    # move the parrot into the right location
    graph =
      Graph.modify(@graph, :parrot, &update_opts(&1, translate: position))
      |> push_graph()

    # start a very simple animation timer
    {:ok, timer} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      timer: timer,
      graph: graph,
      first_scene: first_scene,
      alpha: 0
    }

    {:ok, state}
  end

  # --------------------------------------------------------
  # A very simple animation. A timer runs, which increments a counter. The counter
  # Is applied as an alpha channel to the parrot png.
  # When it is fully saturated, transition to the first real scene
  def handle_info(
        :animate,
        %{timer: timer, alpha: a} = state
      )
      when a >= 256 do
    :timer.cancel(timer)
    Process.send_after(self(), :finish, @finish_delay_ms)
    {:noreply, state}
  end

  def handle_info(:finish, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_info(:animate, %{alpha: alpha, graph: graph} = state) do
    graph =
      graph
      |> Graph.modify(:parrot, &update_opts(&1, fill: {:image, {@parrot_hash, alpha}}))
      |> push_graph()

    {:noreply, %{state | graph: graph, alpha: alpha + 2}}
  end

  # --------------------------------------------------------
  # short cut to go right to the new scene on user input
  def handle_input({:cursor_button, {_, :press, _, _}}, _context, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_input({:key, _}, _context, state) do
    go_to_first_scene(state)
    {:noreply, state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  # --------------------------------------------------------
  defp go_to_first_scene(%{viewport: vp, first_scene: first_scene}) do
    ViewPort.set_root(vp, {first_scene, nil})
  end
end
