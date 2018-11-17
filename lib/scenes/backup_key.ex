defmodule ElixWallet.Scene.BackupKey do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Notes
    alias Elixium.KeyPair
    alias Scenic.ViewPort
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav

    @settings Application.get_env(:elix_wallet, :settings)
    @notes "Random Note"
    @success "Generated Key Pair"

    @parrot_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/Logo.png")
    @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )
    @opts %{translate: {310, 250}, fontsize: 36}
    @parrot_width 480
    @parrot_height 270
    @algorithm :ecdh
    @sigtype :ecdsa
    @curve :secp256k1
    @hashtype :sha256
    @notes """
      Backup A Single Key or All Keys
    """
    @priv_keys Scenic.Cache.get("test_key")
    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
           |> group(
             fn g ->
               g
               |> rect(
                 {@parrot_width, @parrot_height},
                 id: :parrot,
                 fill: {:image, {@parrot_hash, 50}},
                translate: {135, 150}
                 )
               |> text("", translate: {225, 150}, id: :event)
               |> button("Backup Key", id: :btn_single, width: 120, height: 46, theme: :dark, translate: {310, 400})
               |> button("Backup All Keys", id: :btn_all, width: 120, height: 46, theme: :dark, translate: {310, 450})

             end)
           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)
           |> Notes.add_to_graph(@notes)


    def init(_, opts) do
      viewport = opts[:viewport]
      {:ok, keys} = Scenic.Cache.fetch("priv_keys")
      {key, id} = List.first(keys)
      {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
      graph = Graph.build(font: :roboto, font_size: 24, theme: :dark)
             |> group(
               fn g ->
                 g
                 |> rect(
                   {@parrot_width, @parrot_height},
                   id: :parrot,
                   fill: {:image, {@parrot_hash, 50}},
                  translate: {135, 150}
                   )
                 |> text("", translate: {225, 150}, id: :event)
                 |> button("Back", id: :btn_back, width: 80, height: 46, theme: :dark, translate: {10, 80})
                 |> button("Backup", id: :btn_single, width: 80, height: 46, theme: :dark, translate: {10, 200})
                 |> dropdown({keys, id}, id: :dropdown_id, translate: {220, 200})
                 |> button("Backup All", id: :btn_all, width: 80, height: 46, theme: :dark, translate: {10, 260})

               end)
             # Nav and Notes are added last so that they draw on top
             |> Nav.add_to_graph(__MODULE__)
             |> Notes.add_to_graph(@notes)

      push_graph(graph)
      {:ok, %{graph: graph, viewport: opts[:viewport]}}
    end

    def filter_event({:click, :btn_all}, _, graph) do
      {:continue, {:click, :btn_all}, graph}
    end

    def filter_event({:click, :btn_back}, _, %{viewport: vp} = state) do
      ViewPort.set_root(vp, {ElixWallet.Scene.Keys, nil})
      {:continue, {:click, :btn_back}, state}
    end

    def filter_event({:click, :btn_single}, _, graph) do
      private_key = Scenic.Cache.get!("selected_key") |> IO.inspect
      {:continue, {:click, :btn_single}, graph}
    end

    def filter_event({:value_changed, id, selected_item_id}, _, graph) do
      :ets.insert(:scenic_cache_key_table, {"selected_key", 1, selected_item_id})
      {:continue,{:value_changed, id, selected_item_id}, graph}
    end


  end
