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
    @provate_test <<190, 80, 100, 241, 248, 121, 217, 221, 159, 14, 34, 235, 51, 190, 175, 77,
  140, 109, 80, 116, 183, 242, 135, 159, 57, 246, 143, 34, 226, 24, 152, 225>>

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
               |> text_field("",
                 id: :key_input,
                 width: 400,
                 height: 20,
                 fontsize: 15,
                 hint: "Paste Private Key or Pneumonic",
                 translate: {250, 180}
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
      push_graph(@graph)
      {:ok,@graph}
    end

    def filter_event({:click, :btn_import}, _, state) do
      IO.puts "Anbout to fetch graph"
      data = state.primitives[3].data
      get_from_private(@private_test)
      {:continue, {:click, :btn_import}, state}
    end

    def get_from_private(private) do
      #Enum.join(for <<c::utf8 <- @private_test>>, do: <<c::utf8>>) |> IO.inspect
      :crypto.generate_key(@algorithm, @curve, private) |> IO.inspect
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    def filter_event(event, _, graph) do
      {evt, id, value} = event
      if event = {:click, :btn_import} do
        input_struct = Graph.get!(@graph, :key_input)
        input_struct.data
      {:continue, event, graph}
    end

    graph =
      graph
      |> Graph.modify(:event, &text(&1, value))
      |> push_graph()
      {:continue, event, graph}
    end

    defp check_and_write(full_path, {public, private}) do
      if !File.dir?(full_path), do: File.mkdir(full_path)
      pub_hex = Base.encode16(public)
      File.write!(full_path<>"/#{pub_hex}.key", private)
    end

    defp gen_key() do
      256
        |> div(8)
        |> :crypto.strong_rand_bytes()

      binary
        |> :binary.bin_to_list()
        |> Enum.map(fn byte ->
          byte
            |> Integer.to_string(2)
            |> String.pad_leading(8, "0")
          end)
        |> Enum.join()

      entropy_bytes
        |> bit_size()
        |> div(32)

      String.slice(binary_string, 0..(checksum_length - 1))

      ~r/.{1,11}/
        |> Regex.scan(entropy)
        |> List.flatten()
        |> Enum.map(fn part ->
            index = String.to_integer(part, 2)
            Enum.at(@words, index)
          end)
        |> Enum.join(" ")
    end

  end
