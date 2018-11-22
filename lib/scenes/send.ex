defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Confirm
    alias ElixWallet.Component.Nav

    import Scenic.Primitives
    import Scenic.Components


    @settings Application.get_env(:elix_wallet, :settings)
    @theme Application.get_env(:elix_wallet, :theme)
    @graph Graph.build(font: :roboto, font_size: 24)
           |> text("SEND", fill: @theme.nav, id: :small_text, font_size: 26, translate: {500, 50})
           |> text("", fill: {86, 79, 162}, translate: {225, 150}, id: :hidden_add, styles: %{hidden: true})
           |> text("", translate: {225, 150}, id: :hidden_amt, styles: %{hidden: true})
           |> text_field("",
             id: :add,
             width: 600,
             height: 30,
             fontsize: 12,
             styles: %{filter: :all},
             hint: "Address",
             translate: {250, 150}
           )
           |> text("Transaction Amount", fill: @theme.nav, font_size: 24, translate: {200, 320})
           |> text_field("",
             id: :amt,
             width: 100,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Amount",
             translate: {225, 350}
           )
           |> text("Transaction Fee", fill: @theme.nav, font_size: 24, translate: {525, 320})
           |> text("Slow", fill: @theme.nav, font_size: 16, translate: {430, 350})
           |> text("Fast", fill: @theme.nav, font_size: 16, translate: {750, 350})
           |> slider({[0.5, 1.0, 1.5, 2.0, 2.5, 3.0], 0.5}, id: :fee, t: {450, 350})
           |> text("0.5", translate: {575, 400}, id: :hidden_fee)
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {500, 450})
           |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {450, 200})
           |> Nav.add_to_graph(__MODULE__)


    def init(_, _opts) do
      init_cache_files
      push_graph(@graph)
      {:ok, @graph}
    end

    defp init_cache_files do
    end

    def filter_event({evt, id, value}, _, graph) do
      if id == :fee do
        graph =
          graph
          |> Graph.modify(convert_to_hidden_atom(id), &text(&1, Float.to_string(value)))
          |> push_graph()
          {:continue, {evt, id, value}, graph}
      else
        graph =
          graph
          |> Graph.modify(convert_to_hidden_atom(id), &text(&1, value))
          |> push_graph()
          {:continue, {evt, id, value}, graph}
      end
    end

    #def filter_event(event, _, state), do: IO.inspect {:continue, event, state}

    defp convert_to_hidden_atom(atom) do
      [base_atom] = Atom.to_string(atom) |> String.split(":")
      String.to_atom("hidden_" <> base_atom)
    end

    def filter_event({:click, :btn_send}, _, graph) do
      address = Graph.get!(graph, :hidden_add).data
      amount = Graph.get!(graph, :hidden_amt).data
      fee = Graph.get!(graph, :hidden_fee).data

      :ets.insert(:scenic_cache_key_table, {"last_tx_input", 1, {address, amount, fee}})
      graph = graph |> Confirm.add_to_graph("Are you Sure you want to Send the Transaction?", type: :double) |> push_graph()

      {:continue, {:click, :btn_send}, graph}
    end

    def filter_event({:click, :btn_cancel},_, graph) do
      graph = @graph |> push_graph()
      {:continue, {:click,:btn_cancel}, graph}
    end

    def filter_event({:click, :btn_confirm},_, graph) do
      address = Scenic.Cache.get!("last_tx_input") |> elem(0)
      amount = Scenic.Cache.get!("last_tx_input") |> elem(1)
      fee = Scenic.Cache.get!("last_tx_input") |> elem(2)
      transaction = ElixWallet.Helpers.build_transaction(address, amount, fee)
      
      graph = @graph |> push_graph()
      {:continue, {:click, :btn_confirm}, graph}
    end


    def filter_event({:click, :btn_paste}, _, graph) do
      address = Clipboard.paste!()
      graph = graph |> Graph.modify(:add, &text_field(&1, address)) |> push_graph()
      {:continue, {:click, :btn_paste}, graph}
    end





  end
