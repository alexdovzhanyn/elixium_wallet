defmodule ElixiumWallet.Scene.BackupKey do
    use Scenic.Scene
    alias Scenic.Graph
    alias ElixiumWallet.Component.Notes
    alias ElixiumWallet.Utilities
    alias Scenic.ViewPort
    import Scenic.Primitives
    import Scenic.Components

    alias ElixiumWallet.Component.Nav
    @theme Application.get_env(:elixium_wallet, :theme)

    def init(_, opts) do
      keys = Utilities.get_from_cache(:user_keys, "priv_count")
      initial_keys = Utilities.get_from_cache(:user_keys, "priv_keys")
        |> Enum.sort
        |> Enum.take(5)
        |> Enum.map(fn v -> {v, String.to_atom(v)} end)

      graph =
        Graph.build(font: :roboto, font_size: 24, theme: :dark)
        |> rect({620, 200}, fill: :clear, stroke: {2, {255,255,255}}, translate: {190, 200})
        |> text("", id: :mnemonic, font_size: 14, translate: {150, 150})
        |> radio_group(initial_keys, id: :radio_group_id, translate: {200, 250})
        |> slider({{0, keys-1}, 0}, width: 200, id: :num_slider, translate: {800,200}, r: 1.5708)
        |> button("Backup", id: :btn_single, width: 80, height: 46, theme: :dark, translate: {400, 350})
        |> Nav.add_to_graph(__MODULE__)
        |> rect({10, 30}, fill: @theme.nav, translate: {130, 585})
        |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 585})
        |> circle(10, fill: @theme.nav, stroke: {0, :clear}, t: {130, 615})


      push_graph(graph)
      {:ok, %{graph: graph, viewport: opts[:viewport]}}
    end

    def filter_event({:click, :btn_all}, _, graph) do
      {:continue, {:click, :btn_all}, graph}
    end

    def filter_event({:click, :btn_single}, _,  %{graph: graph}) do
      key = Utilities.get_from_cache(:user_keys, "selected_key")
      write_key_to_file(key)
      graph = graph |> Graph.modify(:mnemonic, &text(&1, "Saved!")) |> push_graph()
      {:continue, {:click, :btn_single}, %{graph: graph}}
    end

    def filter_event({:value_changed, :radio_group_id, value}, _, %{graph: graph}) do
      Utilities.store_in_cache(:user_keys, "selected_key", Atom.to_string(value))
      {:continue,{:value_changed, :radio_group_id, value}, %{graph: graph}}
    end

    def filter_event({:value_changed, :num_slider, value}, _, %{graph: graph}) do
      keys = Utilities.get_from_cache(:user_keys, "priv_keys")
        |> Enum.map(fn v -> {v, String.to_atom(v)} end)
        |> Enum.sort()
        |> Enum.chunk_every(5)

      graph =
        graph
        |> Graph.modify(:radio_group_id, &radio_group(&1, Enum.fetch!(keys, value)))
        |> push_graph()
      {:continue,{:value_changed, :num_slider, value}, %{graph: graph}}
    end

    def write_key_to_file(pub) do
      key_location =
        :elixium_core
        |> Application.get_env(:unix_key_address)
        |> Path.expand()

      {public, private} = Elixium.KeyPair.get_from_file(key_location <> "/" <> pub <> ".key")
      mnemonic = Elixium.Mnemonic.from_entropy(private)

      File.write!(key_location <> "/#{pub}_backup.txt", mnemonic)
    end

  end
