defmodule ElixWallet.Scene.ImportKey do

    use Scenic.Scene
    alias Scenic.Graph
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav

    @settings Application.get_env(:elix_wallet, :settings)


    @parrot_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/Logo.png")
    @parrot_hash Scenic.Cache.Hash.file!( @parrot_path, :sha )

    @parrot_width 480
    @parrot_height 270
    @algorithm :ecdh

    @curve :secp256k1

    @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
               |> rect(
                 {@parrot_width, @parrot_height},
                 id: :parrot,
                 fill: {:image, {@parrot_hash, 50}},
                translate: {135, 150}
                 )
               |> text("", translate: {225, 150}, id: :event)
               |> text("Import Keys", id: :small_text, font_size: 26, translate: {475, 100})
               |> text_field("",
                 id: :key_input,
                 width: 700,
                 height: 30,
                 fontsize: 12,
                 hint: "Paste Private Key or Pneumonic",
                 translate: {150, 180}
               )
               |> button("Import", id: :btn_import, width: 80, height: 46, theme: :dark, translate: {450, 300})
               |> Nav.add_to_graph(__MODULE__)


    def init(_, opts) do
      Scenic.Cache.File.load(@parrot_path, @parrot_hash)
      push_graph(@graph)
      {:ok, %{graph: @graph, viewport: opts[:viewport]}}
    end

    def filter_event({:click, :btn_import}, _, %{graph: graph} = state) do
      data = Graph.get!(graph, :key_input).data |> IO.inspect
      #gen_keypair(Base.encode16(@private_test))
      #gen_keypair(@valid_string)

      #get_from_private(@private_test)
      {:continue, {:click, :btn_import}, state}
    end

    def filter_event(event, _, state) do
      {evt, id, value} = event
      state_to_send = ElixWallet.Utilities.update_internal_state(event,state)
      {:continue, {evt, id, value}, state_to_send}
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    defp check_and_write(full_path, {public, private}) do
      if !File.dir?(full_path), do: File.mkdir(full_path)
      pub_hex = Base.encode16(public) |> IO.inspect
      File.write!(full_path<>"/#{pub_hex}.key", private)
    end

    def gen_keypair(phrase) do
      case String.contains?(phrase, " ") do
        true ->
          IO.puts "Public Key/Mnemonic"
          private = ElixWallet.Advanced.to_entropy(phrase) |> IO.inspect
          keys = get_from_private(private) |> IO.inspect
          create_keyfile(keys) |> IO.inspect
        false ->
          IO.puts "Private Key"
          keys = get_from_private(phrase)
          create_keyfile(keys)
      end
    end

    defp get_from_private(private) do
      private
      |> (fn pkey -> :crypto.generate_key(@algorithm, @curve, pkey) end).()
    end


  end
