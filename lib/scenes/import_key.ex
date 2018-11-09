defmodule ElixWallet.Scene.ImportKey do

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

    @bird_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
    @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )
    @parrot_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/Logo.png")
    @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )
    @opts %{translate: {310, 250}, fontsize: 36}
    @parrot_width 480
    @parrot_height 270
    @bird_width 100
    @bird_height 128

    @body_offset 80

    @line {{0, 0}, {60, 60}}

    @notes """
      Import A Key using a Pneumonic or Private Key
    """

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
               |> text("Import Keys", id: :small_text, font_size: 26, translate: {310, 100})
               |> text_field("Sample Text", @opts)
               |> text_field("",
                 id: :key_input,
                 w: 100,
                 height: 20,
                 fontsize: 15,
                 hint: "Paste Private Key or Pneumonic",
                 t: {100, 200}
               )
               |> button("Import Key", id: :btn_import, width: 120, height: 46, theme: :dark, translate: {310, 400})

             end)
           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)
           |> Notes.add_to_graph(@notes)


    def init(_, opts) do
      viewport = opts[:viewport]
      {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

      Scenic.Cache.File.load(@parrot_path, @parrot_hash)


          position = {
            vp_width / 2 - @parrot_width / 2,
            vp_height / 2 - @parrot_height / 2
          }

      Scenic.Cache.File.load(@parrot_path, @parrot_hash)

        push_graph(@graph)



      {:ok,@graph}
    end

    def filter_event({:click, :btn_generate2}, _, graph) do
      IO.puts "Button Clicked Generate"
      with :ok <- create_keyfile(Elixium.KeyPair.create_keypair) do
        IO.puts " Worked, Now publish notifications, before alter"
        graph = graph |> Graph.modify(:event, &text(&1, "Working")) |> push_graph() |> IO.inspect
        {:continue, graph}
      end
    end

    def filter_event({:click, :btn_import}, _, state) do
      IO.puts "Button Clicked Import"
      IO.inspect state
      #
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    def filter_event(event, _, graph) do
      if event = {:click, :btn_import} do
        with :ok <- create_keyfile(Elixium.KeyPair.create_keypair) do
      graph =
        graph
        |> Graph.modify(:event, &text(&1, "Succesfully Generated the Key"))
        |> push_graph()

      {:continue, event, graph}
    end
    end
    end

    defp check_and_write(full_path, {public, private}) do
      if !File.dir?(full_path), do: File.mkdir(full_path)
      pub_hex = Base.encode16(public)
      File.write!(full_path<>"/#{pub_hex}.key", private)
    end

  end
