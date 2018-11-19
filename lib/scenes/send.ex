defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav
    @settings Application.get_env(:elix_wallet, :settings)




    @home_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/home.png")
    @home_hash Scenic.Cache.Hash.file!(@home_path, :sha )


    @graph Graph.build(font: :roboto, font_size: 24)
           |> text("SEND", id: :small_text, font_size: 26, translate: {500, 50})
           |> text("", translate: {225, 150}, id: :hidden_add, styles: %{hidden: true})
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
           |> text("Transaction Amount", font_size: 24, translate: {200, 320})
           |> text_field("",
             id: :amt,
             width: 100,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Amount",
             translate: {225, 350}
           )
           |> text("Transaction Fee", font_size: 24, translate: {525, 320})
           |> text("Slow", font_size: 16, translate: {430, 350})
           |> text("Fast", font_size: 16, translate: {750, 350})
           |> slider({[0.5, 1.0, 1.5, 2.0, 2.5, 3.0], 0.5}, id: :fee, t: {450, 350})
           |> text("0.5", translate: {575, 400}, id: :hidden_fee)
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {500, 450})
           |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {450, 200})
           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)


    def init(_, _opts) do
      #Clipboard.copy("Hello, World!") |> IO.inspect # Copied to clipboard




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
    end

    defp convert_to_hidden_atom(atom) do
      [base_atom] = Atom.to_string(atom) |> String.split(":")
      String.to_atom("hidden_" <> base_atom)
    end

    def filter_event({:click, :btn_send}, _, graph) do
      address = Graph.get!(graph, :hidden_add).data
      amount = Graph.get!(graph, :hidden_amt).data
      fee = Graph.get!(graph, :hidden_fee).data

      ElixWallet.Helpers.new_transaction(address, String.to_float(amount), String.to_float(fee)) |> IO.inspect
      {:continue, {:click, :btn_send}, graph}
    end

    def filter_event({:click, :btn_paste}, _, graph) do
      address = Clipboard.paste!() |> IO.inspect
      graph = graph |> Graph.modify(:add, &text_field(&1, address)) |> push_graph()
      {:continue, {:click, :btn_paste}, graph}
    end





  end
