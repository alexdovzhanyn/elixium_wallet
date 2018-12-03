defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Confirm
    alias ElixWallet.Component.Nav
    alias Scenic.ViewPort
    alias ElixWallet.TransactionHelpers
    alias ElixWallet.Utilities
    import Scenic.Primitives
    import Scenic.Components

    @theme Application.get_env(:elix_wallet, :theme)
    @graph Graph.build(font: :roboto, font_size: 24)
           |> text("SEND", fill: @theme.nav, id: :small_text, font_size: 26, translate: {500, 50})
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
             {"Select", :select},
             {"Ultra Slow", :"0.5"},
             {"Slow", :"1.0"},
             {"Average", :"1.5"},
             {"Fast", :"2.0"},
             {"Ultra Fast", :"2.5"}
             ], :select}, id: :fee, translate: {200, 230})
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {500, 320})
           |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {450, 230})
           |> Nav.add_to_graph(__MODULE__)
           |> rect({10, 30}, fill: @theme.nav, translate: {130, 430})
           |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 430})
           |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 460})


    def init(_, opts) do
      ElixWallet.Utilities.store_in_cache(:user_info, "fee", 1.0)
      graph = push_graph(@graph)
      {:ok,  %{graph: graph, viewport: opts[:viewport]}}
    end

    defp validate_inputs(address, amount, fee) do
      fee = Atom.to_string(fee)
      with true <- is_float(String.to_float(fee)),
            true <- is_float(String.to_float(amount)),
              53 <- byte_size(address) do
              {:ok, address, amount, fee}
      else
        error -> {:error, "Incorrect Inputs"}
      end
    end

    def filter_event({:value_changed, :add, value}, _, state) do
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :add, value}, state)
      {:continue, {:value_changed, :add, value}, state_to_send}
    end

    def filter_event({:value_changed, :fee, value}, _, state) do
      fee_send =
        value
        |> Atom.to_string
        |> String.to_float
      #Graph.get!(state.graph, :fee).data |> IO.inspect
      ElixWallet.Utilities.store_in_cache(:user_info, "fee", fee_send)
    #  graph = state.graph |> Graph.modify(:fee, &update_opts(&1, value)) |> push_graph
      #state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :fee, value}, state, :dropdown)
      {:continue, {:value_changed, :fee, value}, state}
    end

    def filter_event({:value_changed, :amt, value}, _, state) do

      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :amt, value}, state)
      {:continue, {:value_changed, :amt, value}, state_to_send}
    end

    defp integer_or_float(value) do
      if value !== "" do
      codepoints = String.codepoints(value)
      leading = Enum.fetch!(codepoints, 0)
      with true <- String.contains?(value, ".") do
        if leading == "." do
          ["0" | codepoints]
          |> Enum.join
          |> String.to_float
        else
        String.to_float(value)
      end
      else
        false ->
        if value !== "" do
          value = String.to_integer(value)
          value/1
        else
          String.to_float(value)
        end
      end
    else
      :invalid
    end
    end

    def filter_event({:click, :btn_cancel},_, %{graph: graph} = state) do
      graph = @graph |> push_graph()
      {:continue, {:click,:btn_cancel}, state}
    end

    def filter_event({:click, :btn_confirm},_, state) do
      tx_input = ElixWallet.Utilities.get_from_cache(:user_info, "tx_info")
      fee = ElixWallet.Utilities.get_from_cache(:user_info, "fee") |> IO.inspect
      graph = @graph |> push_graph
      Task.async(fn -> GenServer.call(:"Elixir.ElixWallet.TransactionHandler", {:build_transaction, [tx_input.add, tx_input.amt, fee]}, 60000) end)
      {:continue, {:click, :btn_confirm}, %{graph: graph}}
    end

    def filter_event({:click, :btn_paste}, _, %{graph: graph} = state) do
      address = Clipboard.paste!()
      graph = graph |> Graph.modify(:add, &text_field(&1, address)) |> push_graph()
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :add, address}, state)
      {:continue, {:click, :btn_paste}, state_to_send}
    end

    def filter_event({:click, :btn_send}, _, state) do
      {_, add} = Graph.get!(state.graph, :add).data |> IO.inspect
      {_, amt} = Graph.get!(state.graph, :amt).data

   amt_send =
        amt
        |> integer_or_float()
        graph =
        if amt_send !== :invalid do
          if add !== "" do
            if ElixWallet.Utilities.get_from_cache(:user_info, "fee") !== :select do
              ElixWallet.Utilities.store_in_cache(:user_info, "tx_info", %{add: add, amt: amt_send})
              state.graph |> Confirm.add_to_graph("Are you Sure you want to Send the Transaction?", type: :double) |> push_graph()
            else
              state.graph |> Confirm.add_to_graph("Invalid Amount inputted", type: :single) |> push_graph()
            end
          else
            state.graph |> Confirm.add_to_graph("Invalid Amount inputted", type: :single) |> push_graph()
          end
        else
          state.graph |> Confirm.add_to_graph("Invalid Amount inputted", type: :single) |> push_graph()
        end
      state = %{graph: graph}
      {:continue, {:click, :btn_send}, state}
    end






  end
