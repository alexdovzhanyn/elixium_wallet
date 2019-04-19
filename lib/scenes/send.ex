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

    
    @paste_path :code.priv_dir(:elixium_wallet) |> Path.join("/static/images/paste.png")
    @paste_hash Scenic.Cache.Hash.file!(@paste_path, :sha )
    @settings Application.get_env(:elixium_wallet, :settings)
    @algorithm :ecdh
    @sigtype :ecdsa
    @curve :secp256k1
    @hashtype :sha256
    @theme Application.get_env(:elixium_wallet, :theme)
    
    def init(_, opts) do
      ElixiumWallet.Utilities.store_in_cache(:user_info, "fee", 1.0)
      graph = push()
      update_all(graph)
      state = %{
        graph: graph, 
        viewport: opts[:viewport], 
        valid?: {false, false, false, true}, 
        input: %{add: "", fee: "", amt: ""}
      }
      {:ok,  state}
    end

    def push do
      pub_key = get_keys()
      qr_path = @settings.unix_key_location<>"/qr.png"
      qr_hash =  Scenic.Cache.Hash.file!( qr_path, :sha )
      Scenic.Cache.File.load(qr_path, qr_hash)

      graph = 
        Graph.build(font: :roboto, font_size: 24, clear_color: @theme.nav)
        |> rrect({750, 220, 25}, fill: @theme.jade, translate: {180, 100})
        |> rrect({750, 220, 25}, fill: @theme.jade, translate: {180, 400})
        |> text("SEND", fill: @theme.light_text, font_size: 26, translate: {500, 70})
        |> text_field("",
          id: :add,
          width: 600,
          height: 30,
          fontsize: 12,
          styles: %{filter: :all},
          hint: "Address",
          translate: {200, 150}
        )
        |> text("Transaction Amount", fill:  @theme.light_text, font_size: 24, translate: {450, 220})
        |> text_field("",
           id: :amt,
           width: 100,
           height: 30,
           styles: %{filter: :number},
           fontsize: 12,
           hint: "Amount",
           translate: {450, 240}
         )
        |> text("TXCost: 8.8", fill:  @theme.light_text, font_size: 24, translate: {600, 260})
        |> text("Transaction Fee", fill:  @theme.light_text, font_size: 24, translate: {200, 220})
        |> dropdown({[
           {"Select", :select},
           {"Ultra Slow", :"0.5"},
           {"Slow", :"1.0"},
           {"Average", :"1.5"},
           {"Fast", :"2.0"},
           {"Ultra Fast", :"2.5"}
            ], :select}, 
            id: :fee, 
            translate: {200, 240}
          )
        |> button("Send", id: :btn_send, width: 80, height: 46, theme: :success, hidden: :true, translate: {780, 230})
        |> icon("", id: :btn_paste, alignment: :right, width: 48, height: 48, translate: {810, 130}, img: @paste_hash)
        |> text("RECEIVE", fill: @theme.light_text, font_size: 26, translate: {500, 380})
        |> rect(
           {600, 30},
           fill: :clear,
           stroke: {2, {255,255,255}},
           id: :border,
           join: :round,
           translate: {200, 430}
          )
        |> icon("", id: :btn_copy, alignment: :right, width: 48, height: 48, translate: {810, 430}, img: @paste_hash)
        |> rect(
           {130, 130},
           fill: @theme.light_text,
           stroke: {0, :clear},
           id: :image,
           translate: {490, 480}
          )
        |> text(pub_key,id: :pub_address, font_size: 20, height: 15, width: 400, translate: {220, 450})
        |> Nav.add_to_graph(__MODULE__)
           
        push_graph(graph)
        state = %{graph: graph}
        graph
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
          if byte_size(value) < 1 do
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

      input =
      case id do
        :add ->
          %{add: value, fee: state.input.fee, amt: state.input.amt}
        :fee ->
          %{add: state.input.add, fee: value, amt: state.input.amt}
        :amt ->
          %{add: state.input.add, fee: state.input.fee, amt: value}
      end
      
      valid_button = validate_button(valid?)
      {add, amt, fee, button} = valid?
      valid = {add, amt, fee, valid_button}

      update_qr()
      
      state = Map.put(state, :valid?, valid)
      graph = state.graph |> Graph.modify(:btn_send, &update_opts(&1, hidden: :false)) |> update_all |> push_graph
      state = Map.put(state, :graph, graph)
      Map.put(state, :input, input)
    end


    defp validate_button({true, true, true, d}), do: true
    defp validate_button({a, b, c, d}), do: false

    defp alter_event({:value_changed, id, value}, state) when is_atom(id) do

      state = validate_inputs(id, value, state)
      
      state = Map.put(state, :graph, state.graph)
      {:continue, {:value_changed, id, value}, state}
    end

    def filter_event({:value_changed, :add, value}, _, state), do: alter_event({:value_changed, :add, value}, state)
    def filter_event({:value_changed, :amt, value}, _, state), do: alter_event({:value_changed, :amt, value}, state)

    def filter_event({:value_changed, :fee, value}, _, state) do
      fee_send =
        value
        |> Atom.to_string
        |> String.to_float

      ElixiumWallet.Utilities.store_in_cache(:user_info, "fee", fee_send)
      state = validate_inputs(:fee, Atom.to_string(value), state)
      state = Map.put(state, :graph, state.graph)
      {:continue, {:value_changed, :fee, value}, state}
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
      graph = state.graph |> push_graph()
      state = Map.put(state, :graph, graph)
      {:continue, {:click,:btn_cancel}, state}
    end

    def filter_event({:click, :btn_confirm},_, state) do
      tx_input = ElixiumWallet.Utilities.get_from_cache(:user_info, "tx_info")
      fee = ElixiumWallet.Utilities.get_from_cache(:user_info, "fee")
      graph = state.graph |> push_graph
      state = Map.put(state, :graph, graph)
      Task.async(fn -> GenServer.call(:"Elixir.ElixiumWallet.TransactionHandler", {:build_transaction, [tx_input.add, tx_input.amt, fee]}, 60000) end)
      {:continue, {:click, :btn_confirm}, state}
    end


    def filter_event({:click, :btn_copy}, _, %{graph: graph} = state) do
      address = Graph.get!(graph, :pub_address).data
      Clipboard.copy(address)
      :os.cmd('echo #{address} | xclip -selection clipboard')
      {:continue, {:click, :btn_copy}, state}
    end
 

    def filter_event({:click, :btn_paste}, _, state) do
      address = Clipboard.paste!()
    
      state = validate_inputs(:add, address, state)
      graph =
        state.graph
        |> Graph.modify(:add, &text_field(&1, address))
        |> push_graph()
      
      state = Map.put(state, :graph, graph)
      {:continue, {:click, :btn_paste}, state}
    end

    def filter_event({:click, :btn_send}, _, state) do
      case state.valid? do
        {true, true, true, true} ->
           amt_send =
                state.input.amt
                |> integer_or_float()

            graph =
              if amt_send !== :invalid do
                if state.input.add !== "" do
                  if ElixiumWallet.Utilities.get_from_cache(:user_info, "fee") !== :select do
                    ElixiumWallet.Utilities.store_in_cache(:user_info, "tx_info", %{add: state.input.add, amt: amt_send})
                    state.graph |> Confirm.add_to_graph("Are you Sure you want to Send the Transaction?", type: :double) |> push_graph()
                  else
                    state.graph |> Confirm.add_to_graph("Invalid Fee inputted", type: :single) |> push_graph()
                  end
                else
                  state.graph |> Confirm.add_to_graph("Invalid Address inputted", type: :single) |> push_graph()
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
    {:continue, {:click, :btn_send}, state}
  end




  defp get_keys() do
      key_pair = Elixium.KeyPair.create_keypair
      with {:ok, public} <- create_keyfile(key_pair) do
        pub = Elixium.KeyPair.address_from_pubkey(public)
        qr_code_png = 
          pub
          |> EQRCode.encode()
          |> EQRCode.png(width: 120)

        File.write!(@settings.unix_key_location<>"/qr.png", qr_code_png, [:binary])
          pub
      end
    end

  defp update_qr() do
    qr_path = @settings.unix_key_location<>"/qr.png"
    qr_hash =  Scenic.Cache.Hash.file!( qr_path, :sha )
    Scenic.Cache.put(qr_path, qr_hash)
    qr_hash
  end

  defp update_all(graph), do: update_element(graph, :image, update_qr())
  

  defp update_element(graph, id, updated_element) when is_atom(id) do
    graph = graph |> Graph.modify(id, &update_opts(&1, fill: {:image, updated_element})) |> push_graph()
  end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    defp check_and_write(full_path, {public, private}) do
      if !File.dir?(full_path), do: File.mkdir(full_path)
      pub_hex = Elixium.KeyPair.address_from_pubkey(public)
      with :ok <- File.write!(full_path<>"/#{pub_hex}.key", private) do
        {:ok, public}
      end
    end






  end
