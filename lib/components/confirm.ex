defmodule ElixWallet.Component.Confirm do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph


  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]
  import Scenic.Components

  @height 400
  @font_size 20
  @indent 300
  @theme Application.get_env(:elix_wallet, :theme)

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(dialog, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()
      IO.inspect opts

       |> IO.inspect
    graph =
    case opts[:styles].type do
      :double ->
        double_input(dialog) |> push_graph()
      :single ->
        single_input(dialog) |> push_graph()
    end

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end

  defp double_input(dialog) do
    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({1024, 640}, fill: {255,255,255, 50}, translate: {0,0})
      |> rect({600, @height}, fill: {elem(@theme.nav,0),elem(@theme.nav,1),elem(@theme.nav,2)}, translate: {200, 100})
      |> text(dialog, font_size: 26, translate: {@indent, 300})
      |> button("Send", id: :btn_confirm, width: 80, height: 50, translate: {375, 400})
      |> button("Cancel", id: :btn_cancel, width: 80, height: 50, translate: {525, 400})
  end

  defp single_input(dialog) do
    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({1024, 640}, fill: {255,255,255, 50}, translate: {0,0})
      |> rect({600, @height}, fill: {elem(@theme.nav,0),elem(@theme.nav,1),elem(@theme.nav,2)}, translate: {200, 100})
      |> text(dialog, font_size: 26, translate: {@indent, 300})
      |> button("Okay", id: :btn_confirm, width: 80, height: 50, translate: {300, 400})
  end
end
