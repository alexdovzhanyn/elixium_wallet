defmodule ElixWallet.Component.HashGraph do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph


  import Scenic.Primitives
  import Scenic.Components

  @height 30
  @font_size 20
  @indent 225
  @theme Application.get_env(:elix_wallet, :theme)

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(notes, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

      hash_table = Scenic.Cache.get!("network_hash")
      average_hash = Enum.sum(hash_table)/10 |> Kernel.round()
      scale = set_scale(average_hash) |> IO.inspect(label: "SCALE")
      hash_0 = Enum.fetch!(hash_table, 0)*(-1/scale)*100
      hash_1 = Enum.fetch!(hash_table, 1)*(-1/scale)*100
      hash_2 = Enum.fetch!(hash_table, 2)*(-1/scale)*100
      hash_3 = Enum.fetch!(hash_table, 3)*(-1/scale)*100
      hash_4 = Enum.fetch!(hash_table, 4)*(-1/scale)*100
      hash_5 = Enum.fetch!(hash_table, 5)*(-1/scale)*100
      hash_6 = Enum.fetch!(hash_table, 6)*(-1/scale)*100
      hash_7 = Enum.fetch!(hash_table, 7)*(-1/scale)*100
      hash_8 = Enum.fetch!(hash_table, 8)*(-1/scale)*100
      hash_9 = Enum.fetch!(hash_table, 9)*(-1/scale)*100

    graph =
      Graph.build(translate: {0, 0})
      |> text("0", font_size: 20, translate: {180, 610})
      |> text(Integer.to_string(scale), id: :scale, font_size: 20, translate: {180, 450})
      |> line({{200, 620},{900, 620}}, fill: {255,255,255})
      |> line({{200, 620},{200, 450}}, fill: {255,255,255})
      |> path([
        :begin,
        {:move_to, 0, 0},
        {:line_to, 80, hash_0},
        {:line_to, 160, hash_1},
        {:line_to, 240, hash_2},
        {:line_to, 300, hash_3},
        {:line_to, 360, hash_4},
        {:line_to, 420, hash_5},
        {:line_to, 480, hash_6},
        {:line_to, 540, hash_7},
        {:line_to, 600, hash_8},
        {:line_to, 660, hash_9}
        ],
        id: :path_1,
        stroke: {2, :red},
        translate: {200, 600},
        )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end

  defp set_scale(average_hash) when average_hash in 0..300, do: 300
  defp set_scale(average_hash) when average_hash in 300..600, do: 600
  defp set_scale(average_hash) when average_hash in 600..900, do: 900
  defp set_scale(average_hash) when average_hash in 900..1100, do: 1100
  defp set_scale(average_hash) when average_hash in 1100..1300, do: 1300

end
