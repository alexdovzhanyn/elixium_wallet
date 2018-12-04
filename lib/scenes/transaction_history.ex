defmodule ElixiumWallet.Scene.TransactionHistory do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort

  alias ElixiumWallet.Component.Nav

  @theme Application.get_env(:elixium_wallet, :theme)
  @header   "Id                         Amount                  Status                Valid Transaction"

  [
    {1, %{amount: 111, id: 1, status: "pending", valid?: true}},
    {3, %{amount: 111, id: 3, status: "pending", valid?: true}},
    {2, %{amount: 111, id: 2, status: "invalid", valid?: false}}
  ]




  def init(_, opts) do
    tx_list = process_transaction_cache |> Enum.take(10)
    graph = Graph.build(font: :roboto, font_size: 24)
           |> text("TransactionHistory", fill: @theme.nav, font_size: 26, translate: {150, 100})
           |> text(Enum.fetch!(tx_list, 0), font_size: 14, id: :tx_1, translate: {200, 200})
           |> text(Enum.fetch!(tx_list, 1), font_size: 14, id: :tx_2, translate: {200, 220})
           |> text(Enum.fetch!(tx_list, 2), font_size: 14, id: :tx_3, translate: {200, 240})
           |> text(Enum.fetch!(tx_list, 3), font_size: 14, id: :tx_4, translate: {200, 260})
           |> text(Enum.fetch!(tx_list, 4), font_size: 14, id: :tx_5, translate: {200, 280})
           |> text(Enum.fetch!(tx_list, 5), font_size: 14, id: :tx_6, translate: {200, 300})
           |> text(Enum.fetch!(tx_list, 6), font_size: 14, id: :tx_7, translate: {200, 320})
           |> text(Enum.fetch!(tx_list, 7), font_size: 14, id: :tx_8, translate: {200, 340})
           |> text(Enum.fetch!(tx_list, 8), font_size: 14, id: :tx_9, translate: {200, 360})
           |> text(Enum.fetch!(tx_list, 9), font_size: 14, id: :tx_10, translate: {200, 380})
           |> text(@header, translate: {200, 175})
           |> Nav.add_to_graph(__MODULE__)
           |> rect({10, 30}, fill: @theme.nav, translate: {130, 365})
           |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 365})
           |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 395})
           |> push_graph()


    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end

  defp process_transaction_cache do
    transactions = ElixiumWallet.Utilities.get_cache_transactions()
    built_list = transactions |> Enum.map(fn tx -> transact_to_string(tx) end)
    size = Enum.count(built_list)
    if size < 10 do
      to_add = 10 - size
      null_tx = 1..to_add |> Enum.map(fn empty -> "" end)
      built_list ++ null_tx
    else
      built_list
    end
  end

  defp transact_to_string({cache_id, %{amount: amount, id: id, status: status, valid?: valid}}) do
    "Id: #{id}              Amount: #{amount}             Status: #{status}             Valid Transaction: #{valid}"
  end



end
