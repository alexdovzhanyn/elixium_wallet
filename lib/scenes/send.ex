defmodule ElixWallet.Scene.Send do

    use Scenic.Scene
    alias Scenic.Graph
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav


    @bird_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
    @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )

    @bird_width 100
    @bird_height 128

    @body_offset 80

    @line {{0, 0}, {60, 60}}

    @notes """
      \"Primitives\" shows the various primitives available in Scenic.
      It also shows a sampling of the styles you can apply to them.
    """

    @graph Graph.build(font: :roboto, font_size: 24)
           |> text("SEND", id: :small_text, font_size: 26, translate: {350, 100})
           |> text("", translate: {225, 150}, id: :hidden_add, styles: %{hidden: true})
           |> text("", translate: {225, 150}, id: :hidden_amt, styles: %{hidden: true})
           |> text("", translate: {225, 150}, id: :hidden_fee, styles: %{hidden: true})
           |> text_field("",
             id: :add,
             width: 600,
             height: 30,
             fontsize: 12,
             styles: %{filter: :all},
             hint: "Address",
             translate: {110, 180}
           )
           |> text_field("",
             id: :amt,
             width: 50,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Amount",
             translate: {150, 215}
           )
           |> text_field("",
             id: :fee,
             width: 50,
             height: 30,
             styles: %{filter: :number},
             fontsize: 12,
             hint: "Fee",
             translate: {150, 250}
           )
           |> button("Send", id: :btn_send, width: 80, height: 46, theme: :dark, translate: {10, 200})
           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)


    def init(_, _opts) do
      # load the parrot texture into the cache
      Scenic.Cache.File.load(@bird_path, @bird_hash)

      push_graph(@graph)

      {:ok, @graph}
    end

    def filter_event({evt, id, value}, _, graph) do
      #{evt, id, value} = event
      graph =
        graph
        |> Graph.modify(convert_to_hidden_atom(id), &text(&1, value))
        |> push_graph()
      {:continue, {evt, id, value}, graph}
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





  end
