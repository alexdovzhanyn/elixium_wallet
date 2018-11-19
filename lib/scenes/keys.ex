defmodule ElixWallet.Scene.Keys do

    use Scenic.Scene
    alias Scenic.Graph
    alias ElixWallet.Component.Notes
    alias Elixium.KeyPair
    alias Scenic.ViewPort
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav
    @theme Application.get_env(:elix_wallet, :theme)
    @settings Application.get_env(:elix_wallet, :settings)
    @notes "Random Note"
    @success "Generated Key Pair"

    @bird_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
    @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )
    @parrot_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/Logo.png")
    @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )

    @parrot_width 480
    @parrot_height 270
    @bird_width 100
    @bird_height 128
    @body_offset 80

    @line {{0, 0}, {60, 60}}

    @notes """
      Generate, Import & Backup Your Keys
    """

    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
           |> group(
             fn g ->
               g
               |> rect(
                 {@parrot_width, @parrot_height},
                 id: :parrot,
                 fill: {:image, {@parrot_hash, 50}},
                translate: {300, 150}
                 )
               
               |> text("", translate: {150, 150}, id: :event)
               |> text("", font_size: 12, translate: {5, 180}, id: :hint)
               |> text("KEY CONFIGURATION", id: :small_text, font_size: 26, translate: {425, 50})
               |> button("Generate", id: :btn_generate, width: 80, height: 46, fill: {:image, {@parrot_hash, 50}}, translate: {135, 200})
               |> button("Import", id: :btn_import, width: 80, height: 46, theme: :dark, translate: {135, 275})
               |> button("Export", id: :btn_export, width: 80, height: 46, theme: :dark, translate: {135, 350})

             end)
           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)
           |> Notes.add_to_graph(@notes)


    def init(_, opts) do
      viewport = opts[:viewport]
      get_keys()
      {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
      Scenic.Cache.File.load(@parrot_path, @parrot_hash)
      push_graph(@graph)

      {:ok, %{graph: @graph, viewport: opts[:viewport]}}
    end

    def get_keys() do
      keys = :ets.lookup(:user_keys, "priv_keys")
    end


    def filter_event({:click, :btn_import}, _, %{viewport: vp} = state) do
      ViewPort.set_root(vp, {ElixWallet.Scene.ImportKey, nil})
    end

    def filter_event({:click, :btn_export}, _, %{viewport: vp} = state) do
      keys = :ets.lookup(:user_keys, "priv_keys")
      priv_keys = Enum.map(keys, fn({k, v}) -> v end)
      :ets.insert(:scenic_cache_key_table, {"priv_keys", 1, priv_keys})
      ViewPort.set_root(vp, {ElixWallet.Scene.BackupKey, nil})
    end

    def filter_event({:click, :btn_generate}, _, %{graph: graph}) do
      with {:ok, mnemonic} <- create_keyfile(Elixium.KeyPair.create_keypair) do
        graph =
          graph
          |> Graph.modify(:event, &text(&1, "Succesfully Generated the Key, Please write down the mnemonic"))
          |> Graph.modify(:hint, &text(&1, mnemonic))
          |> push_graph()
#
      {:continue, {:click, :btn_generate}, graph}
    end
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    def filter_event(event, _, graph) do
      #if event = {:click, :btn_generate} do
      #  with :ok <- create_keyfile(Elixium.KeyPair.create_keypair) do
      #    IO.inspect "Worked ok"
      #  graph =
      #    graph
      #    |> Graph.modify(:event, &text(&1, "Succesfully Generated the Key"))
      #    |> push_graph()
#
    #  {:continue, event, graph}
  #  end
    #end
    end

    defp check_and_write(full_path, {public, private}) do
      mnemonic = ElixWallet.Advanced.from_entropy(private)
      if !File.dir?(full_path), do: File.mkdir(full_path)
      address = Elixium.KeyPair.address_from_pubkey(public)
      with :ok <- File.write!(full_path<>"/#{address}.key", private) do
        {:ok, mnemonic}
      end
    end



  end
