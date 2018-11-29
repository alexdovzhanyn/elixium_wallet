defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Confirm
    alias ElixWallet.Component.Nav
    alias Scenic.ViewPort
    alias ElixWallet.TransactionHelpers

    import Scenic.Primitives
    import Scenic.Components

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
           |> text("Transaction Amount", fill: @theme.nav, font_size: 24, translate: {720, 210})
           |> text_field("",
             id: :amt,
             width: 100,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Amount",
             translate: {750, 230}
           )
           |> text("Transaction Fee", fill: @theme.nav, font_size: 24, translate: {200, 210})
           |> dropdown({[
        {"Ultra Slow", :"0.5"},
        {"Slow", :"1.0"},
        {"Average", :"1.5"},
        {"Fast", :"2.0"},
        {"Ultra Fast", :"2.5"}
      ], :"1.5"}, id: :fee, translate: {200, 230})
           |> text("0.5", fill: @theme.nav, translate: {250, 300}, id: :hidden_fee)
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {500, 320})
           |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {450, 230})
           |> Nav.add_to_graph(__MODULE__)


    def init(_, opts) do
      graph = push_graph(@graph)
      {:ok,  %{graph: graph, viewport: opts[:viewport]}}
    end

    defp validate_inputs(address, amount) do
      with true <- is_float(String.to_float(amount)),
            53 <- byte_size(address) do
              {:ok, address, amount}
      else
        false -> {:error, "Incorrect Inputs"}
      end
    end

    def filter_event({:value_changed, :add, value}, _, state) do
      IO.inspect state
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :add, value}, state)
      {:continue, {:value_changed, :add, value}, state_to_send}
    end

    def filter_event({:value_changed, :fee, value}, _, state) do
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :fee, value}, state)
      {:continue, {:value_changed, :fee, value}, state_to_send}
    end

    def filter_event({:value_changed, :amt, value}, _, state) do
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :amt, value}, state)
      {:continue, {:value_changed, :amt, value}, state_to_send}
    end

    def filter_event({:click, :btn_cancel},_, %{graph: graph} = state) do
      graph = @graph |> push_graph()
      {:continue, {:click,:btn_cancel}, state}
    end

    def filter_event({:click, :btn_confirm},_, %{graph: graph} = state) do
      address = Scenic.Cache.get!("last_tx_input") |> elem(0)
      amount = Scenic.Cache.get!("last_tx_input") |> elem(1)
      fee = Scenic.Cache.get!("last_tx_input") |> elem(2)
      TransactionHelpers.build_transaction(address, amount, fee)
      graph = @graph |> push_graph()
      {:continue, {:click, :btn_confirm}, state}
    end


    def filter_event({:click, :btn_paste}, _, %{graph: graph} = state) do
      address = Clipboard.paste!()
      graph = graph |> Graph.modify(:add, &text_field(&1, address)) |> push_graph()
      amount = Graph.get!(graph, :hidden_amt).data
      fee = Graph.get!(graph, :hidden_fee).data
      Scenic.Cache.put("last_tx_input", {address, amount, fee})
      {:continue, {:click, :btn_paste}, state}
    end

    def filter_event({:click, :btn_send}, _, %{graph: graph} = state) do
      Graph.get!(graph, :add).data |> IO.inspect
      Graph.get!(graph, :amt).data |> IO.inspect
      #transaction = ElixWallet.Helpers.build_transaction(address, "1.0", "1.0")
      #case validate_inputs(address, amount) do
    #  {:ok, address, amount} ->
      #  Scenic.Cache.put("last_tx_input", {address, amount, "1.0"})
      #  graph = graph |> Confirm.add_to_graph("Are you Sure you want to Send the Transaction?", type: :double) |> push_graph()
      #{:error, message} ->
    #    graph = graph |> Confirm.add_to_graph("There was an Error in the Address or Fee", type: :single) |> push_graph()
    #  end
      {:continue, {:click, :btn_send}, graph}
    end






  end
