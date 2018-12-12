defmodule ElixiumWallet.Scene.Recieve do

    use Scenic.Scene
    alias Scenic.Graph
    alias ExixWallet.QRCode
    import Scenic.Primitives
    import Scenic.Components

    alias ElixiumWallet.Component.Nav

    @settings Application.get_env(:elixium_wallet, :settings)
    @theme Application.get_env(:elixium_wallet, :theme)
    @algorithm :ecdh
    @sigtype :ecdsa
    @curve :secp256k1
    @hashtype :sha256


    def init(_, opts) do
      graph = push()
      update_all(graph)
      state = %{graph: graph}
      {:ok, state}
    end

    defp push() do
      pub_key = get_keys()
      qr_path = @settings.unix_key_location<>"/qr.png"
      qr_hash =  Scenic.Cache.Hash.file!( qr_path, :sha )
      Scenic.Cache.File.load(qr_path, qr_hash)
      graph = Graph.build(font: :roboto, font_size: 24, clear_color: {10, 10, 10})
             |> text("RECEIVE", id: :title, font_size: 26, translate: {150, 70})
             |> text("Your Receiving address:", font_size: 24, height: 15, width: 400, translate: {425, 130})
             |> rect(
               {650, 50},
               fill: :clear,
               stroke: {2, {255,255,255}},
               id: :border,
               join: :round,
               translate: {240, 150}
             )
             |> rect(
               {305, 305},
               stroke: {0, :clear},
               id: :image,
               translate: {400, 290}
             )
             |> text(pub_key,id: :pub_address, font_size: 24, height: 15, width: 400, translate: {250, 180})
             |> button("Copy to Clipboard", id: :btn_copy, width: 200, height: 46, theme: :dark, translate: {450, 225})
             |> Nav.add_to_graph(__MODULE__)
             |> rect({10, 30}, fill: @theme.nav, translate: {130, 290})
             |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 290})
             |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 320})
      push_graph(graph)
      state = %{graph: graph}
      graph
    end

    defp get_keys() do
      key_pair = Elixium.KeyPair.create_keypair
      with {:ok, public} <- create_keyfile(key_pair) do
        pub = Elixium.KeyPair.address_from_pubkey(public)
        qr_code_png = pub
                    |> EQRCode.encode()
                    |> EQRCode.png(width: 300)

        File.write!(@settings.unix_key_location<>"/qr.png", qr_code_png, [:binary])
          pub
      end
    end

    defp update_all(graph) do
      qr_path = @settings.unix_key_location<>"/qr.png"
      qr_hash =  Scenic.Cache.Hash.file!( qr_path, :sha )
      Scenic.Cache.put(qr_path, qr_hash)
      graph = graph |> Graph.modify(:image, &update_opts(&1, fill: {:image, qr_hash})) |> push_graph()
    end

    def filter_event(event, _, %{graph: graph} = state) do
      if event == {:click, :btn_copy} do
        address = Graph.get!(graph, :pub_address).data
        case :os.type do
          {:unix, :darwin} -> :os.cmd('echo #{address} | pbcopy')
          {:unix, :linux} -> :os.cmd('echo #{address} | xclip -selection c')
        end
      end
     {:continue, event, state}
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


    def filter_event({:click, :btn_copy}, _, %{graph: graph} = state) do
      address = Graph.get!(graph, :pub_address).data
      #:os.cmd('echo #{address} | xclip -selection c')
      {:continue, {:click, :btn_copy}, state}
    end

  end
