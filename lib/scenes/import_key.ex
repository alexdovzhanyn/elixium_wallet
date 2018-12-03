defmodule ElixWallet.Scene.ImportKey do

    use Scenic.Scene
    alias Scenic.Graph
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav

    @settings Application.get_env(:elix_wallet, :settings)
    @theme Application.get_env(:elix_wallet, :theme)

    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
               |> text("", translate: {225, 150}, id: :event)
               |> text("Import Keys", font_size: 26, translate: {475, 100})
               |> text_field("",
                 id: :key_input,
                 width: 700,
                 height: 30,
                 fontsize: 12,
                 hint: "Paste Private Key or Pneumonic",
                 translate: {150, 180}
               )
               |> button("Paste from Clipboard", id: :btn_paste, width: 175, height: 46, theme: :dark, translate: {400, 230})
               |> button("Import", id: :btn_import, width: 80, height: 46, theme: :dark, translate: {450, 300})
               |> Nav.add_to_graph(__MODULE__)
               |> rect({10, 30}, fill: @theme.nav, translate: {130, 520})
               |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 520})
               |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 550})

    def init(_, opts) do
      push_graph(@graph)
      {:ok, %{graph: @graph, viewport: opts[:viewport]}}
    end

    def filter_event({:click, :btn_paste}, _, %{graph: graph} = state) do
      address = Clipboard.paste!()
      graph = graph |> Graph.modify(:key_input, &text_field(&1, address)) |> push_graph()
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :key_input, address}, state)
      {:continue, {:click, :btn_paste}, state_to_send}
    end

    def filter_event({:click, :btn_import}, _, %{graph: graph} = state) do
      {_, data} = Graph.get!(graph, :key_input).data

      Elixium.KeyPair.gen_keypair(data)

      {:continue, {:click, :btn_import}, state}
    end

    def filter_event({:value_changed, :key_input, value}, _, state) do
      state_to_send = ElixWallet.Utilities.update_internal_state({:value_changed, :key_input, value}, state)
      {:continue, {:value_changed, :add, value}, state_to_send}
    end

    def filter_event(event, _, state) do
      {evt, id, value} = event
      state_to_send = ElixWallet.Utilities.update_internal_state(event,state)
      {:continue, {evt, id, value}, state_to_send}
    end




  end
