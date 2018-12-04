defmodule ElixiumWallet.Component.Confirm do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph


  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]
  import Scenic.Components

  @height 150
  @font_size 20
  @indent 400
  @theme Application.get_env(:elixium_wallet, :theme)

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(dialog, opts) do
    # Get the viewport width
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
      |> rect({500, @height}, stroke: {2, :white}, fill: {elem(@theme.nav,0),elem(@theme.nav,1),elem(@theme.nav,2)}, translate: {300, 225})
      |> text(dialog, font_size: 24, translate: {@indent-75, 275})
      |> button("Send", id: :btn_confirm, width: 80, height: 50, translate: {440, 315})
      |> button("Cancel", id: :btn_cancel, width: 80, height: 50, translate: {560, 315})
  end

  defp single_input(dialog) do
    graph =
      Graph.build(font_size: @font_size, translate: {0, 0})
      |> rect({1024, 640}, fill: {255,255,255, 50}, translate: {0,0})
      |> rect({400, @height}, stroke: {2, :white}, fill: {elem(@theme.nav,0),elem(@theme.nav,1),elem(@theme.nav,2)}, translate: {350, 225})
      |> text(dialog, font_size: 24, translate: {@indent+50, 275})
      |> button("Okay", id: :btn_cancel, width: 80, height: 50, translate: {500, 315})
  end
end
