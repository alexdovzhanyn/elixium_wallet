defmodule ElixWallet.Component.Notes do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph


  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]

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

    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({vp_width, @height}, fill: @theme.notes)
      |> text(notes, translate: {@indent, @font_size * 1})
      |> text("version 0.0.1", translate: {550, @font_size*1})
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end
