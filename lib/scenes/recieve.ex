defmodule ElixWallet.Scene.Recieve do

    use Scenic.Scene
    alias Scenic.Graph
    alias ExixWallet.QRCode
    import Scenic.Primitives
    import Scenic.Components

    alias ElixWallet.Component.Nav

    @settings Application.get_env(:elix_wallet, :settings)
    @bird_path :code.priv_dir(:elix_wallet)
               |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
    @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )

    @bird_width 100
    @bird_height 128

    @qr_path :code.priv_dir(:elix_wallet)
                 |> Path.join("/static/images/qrcode.png")
                 @qr :code.priv_dir(:elix_wallet)
                              |> Path.join("/static/images")
    @qr_hash Scenic.Cache.Hash.file!( @qr_path, :sha )

    @body_offset 80

    @line {{0, 0}, {60, 60}}
    @algorithm :ecdh
    @sigtype :ecdsa
    @curve :secp256k1
    @hashtype :sha256

    @first_row ["\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m", "\e[0;107m  \e[0m",
   "\e[0;107m  \e[0m", "\e[0;107m  \e[0m"]



    def init(_, _opts) do
      {pub_key1, pub_key2} = get_keys() |> String.split_at(64)
      {pubkey1, pubkey2} = pub_key1 |> String.split_at(32)
      {pubkey3, pubkey4} = pub_key2 |> String.split_at(32)
      Scenic.Cache.File.load(@qr_path, @qr_hash)
      graph = Graph.build(font: :roboto, font_size: 24)
             |> text("RECEIVE", id: :title, font_size: 26, translate: {275, 100})
             #|> text_field(pub_key, id: :pub, char_size: 12, width: 200, translate: {105, 200})
             |> text("Your Receiving address:", font_size: 24, height: 15, width: 400, translate: {175, 135})
             |> rect(
               {450, 100},
               fill: :clear,
               stroke: {2, {255,255,255}},
               id: :border,
               translate: {125, 150}
             )
             |> rect(
               {300, 300},
               id: :qr_code,
               fill: {:image, {@qr_hash, 50}},
               translate: {175, 260}
               )
             |> text(pubkey1, font_size: 24, height: 15, width: 400, translate: {150, 180})
             |> text(pubkey2, font_size: 24, height: 15, width: 400, translate: {150, 200})
             |> text(pubkey3, font_size: 24, height: 15, width: 400, translate: {150, 220})
             |> text(pubkey4, font_size: 24, height: 15, width: 400, translate: {150, 240})

             |> Nav.add_to_graph(__MODULE__)
      push_graph(graph)

      {:ok, graph}
    end


    defp get_keysold() do
      [{id, priv}] = :ets.lookup(:user_keys, "priv_keys") |> Enum.take_random(1)
      private_key = Atom.to_string(elem(priv, 1)) |> IO.inspect
      {pub_key, priv_key} = :crypto.generate_key(@algorithm, @curve, private_key) |> IO.inspect
      Base.encode16(pub_key) |> IO.inspect
    end

    defp get_keys() do
      ElixWallet.QRCode.encode("https://www.google.com.au") |> ElixWallet.QRCode.render()
      mnemonic = ElixWallet.Advanced.generate()
      IO.puts "Back to Entropy"
      ElixWallet.Advanced.to_entropy(mnemonic)
      key_pair = Elixium.KeyPair.create_keypair
      with {:ok, public} <- create_keyfile(key_pair) do
        pub = Base.encode16(public) |> IO.inspect
        qr_code_png = pub
                    |> EQRCode.encode()
                    |> EQRCode.png()

        with :ok <- File.write(@qr<>"/qr.png", qr_code_png, [:binary]) do
          pub
        end
      end
    end

    defp create_keyfile({public, private}) do
      case :os.type do
        {:unix, _} -> check_and_write(@settings.unix_key_location, {public, private})
        {:win32, _} -> check_and_write(@settings.win32_key_location, {public, private})
      end
    end

    defp check_and_write(full_path, {public, private}) do
      if !File.dir?(full_path), do: File.mkdir(full_path)
      pub_hex = Base.encode16(public)
      with :ok <- File.write!(full_path<>"/#{pub_hex}.key", private) do
        {:ok, public}
      end
    end


  end
