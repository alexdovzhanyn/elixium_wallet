defmodule ElixiumWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixiumWallet.Component.Confirm
    alias ElixiumWallet.Component.Nav
    alias Scenic.ViewPort
    alias ElixiumWallet.TransactionHelpers
    alias ElixiumWallet.Utilities
    import Scenic.Primitives
    import Scenic.Components

    @theme Application.get_env(:elixium_wallet, :theme)
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
      ElixiumWallet.Utilities.store_in_cache(:user_info, "fee", 1.0)
      graph = push_graph(@graph)
      {:ok,  %{graph: graph, viewport: opts[:viewport], valid?: {false, false, false, true}}}
    end

    defp validate_inputs(id, value, state) do
      add = elem(state.valid?, 0)
      amt = elem(state.valid?, 1)
      fee = elem(state.valid?, 2)
      button = elem(state.valid?, 3)

      valid? =
      case id do
        :add ->
          if byte_size(value) !== 53 do
            {false, amt, fee, button}
          else
            {true, amt, fee, button}
          end
        :fee ->
          if byte_size(Atom.to_string(value)) < 1 do
            {add, amt, false, button}
          else
            {add, amt, true, button}
          end
      :amt ->
        if byte_size(value) < 1 do
          {add, false, fee, button}
        else
          {add, true, fee, button}
        end
      end

      valid_button = validate_button(valid?)
      {add, amt, fee, button} = valid?
      {add, amt, fee, valid_button}
    end

    defp validate_button({true, true, true, d}), do: true
    defp validate_button({a, b, c, d}), do: false


    def filter_event({:value_changed, :add, value}, _, state) do
      valid? = validate_inputs(:add, value, state)
      updated_state = ElixiumWallet.Utilities.update_internal_state({:value_changed, :add, value}, state)
      state_to_send = Map.put(updated_state, :valid?, state)
      {:continue, {:value_changed, :add, value}, state_to_send}
    end

    def filter_event({:value_changed, :fee, value}, _, state) do
      fee_send =
        value
        |> Atom.to_string
        |> String.to_float

      ElixiumWallet.Utilities.store_in_cache(:user_info, "fee", fee_send)
      valid? = validate_inputs(:fee, value, state)

      state = Map.put(state, :valid?, valid?)
      {:continue, {:value_changed, :fee, value}, state}
    end

    def filter_event({:value_changed, :amt, value}, _, state) do
      valid? = validate_inputs(:amt, value, state)

      updated_state = ElixiumWallet.Utilities.update_internal_state({:value_changed, :amt, value}, state)
      state_to_send = Map.put(updated_state, :valid?, valid?)
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

    def filter_event({:click, :btn_cancel},_, state) do
      graph = @graph |> push_graph()
      state = Map.put(state, :graph, graph)
      {:continue, {:click,:btn_cancel}, state}
    end

    def filter_event({:click, :btn_confirm},_, state) do
      tx_input = ElixiumWallet.Utilities.get_from_cache(:user_info, "tx_info")
      fee = ElixiumWallet.Utilities.get_from_cache(:user_info, "fee")
      graph = @graph |> push_graph
      state = Map.put(state, :graph, graph)
      Task.async(fn -> GenServer.call(:"Elixir.ElixiumWallet.TransactionHandler", {:build_transaction, [tx_input.add, tx_input.amt, fee]}, 60000) end)
      {:continue, {:click, :btn_confirm}, state}
    end

    def filter_event({:click, :btn_paste}, _, state) do
      address = Clipboard.paste!()
      graph = state.graph |> Graph.modify(:add, &text_field(&1, address)) |> push_graph()
      updated_state = ElixiumWallet.Utilities.update_internal_state({:value_changed, :add, address}, state)
      valid? = validate_inputs(:add, address, state)
      state_to_send = Map.put(updated_state, :valid?, valid?)
      {:continue, {:click, :btn_paste}, state_to_send}
    end

    def filter_event({:click, :btn_send}, _, state) do
      case state.valid? do
        {true, true, true, true} ->
          {_, add} = Graph.get!(state.graph, :add).data
          {_, amt} = Graph.get!(state.graph, :amt).data
           amt_send =
                amt
                |> integer_or_float()
                graph =
                if amt_send !== :invalid do
                  if add !== "" do
                    if ElixiumWallet.Utilities.get_from_cache(:user_info, "fee") !== :select do
                      ElixiumWallet.Utilities.store_in_cache(:user_info, "tx_info", %{add: add, amt: amt_send})
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
           error ->
            graph = state.graph |> Confirm.add_to_graph("Invalid Details inputted", type: :single) |> push_graph()
            state = %{graph: graph}
            {:continue, {:click, :btn_send}, state}
    end
  end






  end
