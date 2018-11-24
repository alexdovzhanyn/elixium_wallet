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
           |> text("Transaction Amount", fill: @theme.nav, font_size: 24, translate: {450, 320})
           |> text_field("",
             id: :amt,
             width: 100,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Amount",
             translate: {500, 350}
           )
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {500, 450})
           |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {450, 200})
           |> Nav.add_to_graph(__MODULE__)


    def init(_, _opts) do
      push_graph(@graph)
      {:ok, @graph}
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
      {:continue, {evt, id, value}, graph}
    end

    defp convert_to_hidden_atom(atom) do
      [base_atom] = Atom.to_string(atom) |> String.split(":")
      String.to_atom("hidden_" <> base_atom)
    end

    def filter_event({:click, :btn_send}, _, graph) do
      address = Graph.get!(graph, :hidden_add).data
      amount = Graph.get!(graph, :hidden_amt).data
      case validate_inputs(address, amount) do
      {:ok, address, amount} ->
        Scenic.Cache.put("last_tx_input", {address, amount, "1.0"})
        graph = graph |> Confirm.add_to_graph("Are you Sure you want to Send the Transaction?", type: :double) |> push_graph()
      {:error, message} ->
        graph = graph |> Confirm.add_to_graph("There was an Error in the Address or Fee", type: :single) |> push_graph()
      end
      {:continue, {:click, :btn_send}, graph}
    end

    defp validate_inputs(address, amount) do
      with true <- is_float(String.to_float(amount)),
            53 <- byte_size(address) do
              {:ok, address, amount}
      else
        false -> {:error, "Incorrect Inputs"}
      end
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
      amount = Graph.get!(graph, :hidden_amt).data
      Scenic.Cache.put("last_tx_input", {address, amount, "1.0"})
      {:continue, {:click, :btn_paste}, graph}
    end





  end
