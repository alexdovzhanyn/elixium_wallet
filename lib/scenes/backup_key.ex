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
    require Logger
    @store "keys"

    def init(_, opts) do
      keys = Utilities.get_from_cache(:user_keys, "priv_count")
      extent =
      if keys > 1 do
        keys
      else
        2
      end

      initial_keys = Utilities.get_from_cache(:user_keys, "priv_keys")

      init_count = Enum.count(initial_keys)
      initial_keys =
      if init_count < 5 do
        initial_keys
        |> Enum.sort
        |> Enum.take(init_count)
        |> Enum.map(fn v -> {v, String.to_atom(v)} end)
      else
        initial_keys
        |> Enum.sort
        |> Enum.take(5)
        |> Enum.map(fn v -> {v, String.to_atom(v)} end)
      end


      graph =
        Graph.build(font: :roboto, font_size: 24, theme: :dark)
        |> rrect({620, 200, 10}, stroke: {2, {255,255,255}}, translate: {250, 300})
        |> text("", id: :mnemonic, font_size: 26, translate: {450, 200})
        |> text("Backup Key", fill: @theme.nav, font_size: 26, translate: {150, 70})
        |> radio_group(initial_keys, fill: :black, id: :radio_group_id, translate: {300, 350})
        |> slider({{0, extent-1}, 0}, width: 200, id: :num_slider, translate: {850,300}, r: 1.5708)
        |> button("Backup", id: :btn_single, width: 80, height: 46, theme: :dark, translate: {500, 550})
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
      key = Utilities.get_from_cache(:user_keys, "selected_key") |> IO.inspect
      with :ok <- write_key_to_file(key) do
        graph = graph |> Graph.modify(:mnemonic, &text(&1, "Backup Key Saved!")) |> push_graph()
        {:continue, {:click, :btn_single}, %{graph: graph}}
      else
        :error ->
          graph = graph |> Graph.modify(:mnemonic, &text(&1, "Please ensure You selected a key")) |> push_graph()
          {:continue, {:click, :btn_single}, %{graph: graph}}
      end
    end

    def filter_event({:value_changed, :radio_group_id, value}, _, %{graph: graph}) do
      Utilities.store_in_cache(:user_keys, "selected_key", Atom.to_string(value))
      Logger.info("Selected Key:   #{Atom.to_string(value)}")
      {:continue,{:value_changed, :radio_group_id, value}, %{graph: graph}}
    end

    def filter_event({:value_changed, :num_slider, value}, _, %{graph: graph}) do
      keys = Utilities.get_from_cache(:user_keys, "priv_keys")

        key_count = Enum.count(keys)

        keys =
        if key_count < 5 do
          keys
          |> Enum.map(fn v -> {v, String.to_atom(v)} end)
          |> Enum.sort()
        else
          keys
          |> Enum.map(fn v -> {v, String.to_atom(v)} end)
          |> Enum.sort()
          |> Enum.chunk_every(5)
        end

      graph =
        graph
        |> Graph.modify(:radio_group_id, &radio_group(&1, Enum.fetch!(keys, value)))
        |> push_graph()
      {:continue,{:value_changed, :num_slider, value}, %{graph: graph}}
    end

    def write_key_to_file(pub) do
      if pub !== [] do
        unix_address = Elixium.Store.store_path(@store)
        {public, private} = Elixium.KeyPair.get_from_file(unix_address <> "/" <> pub <> ".key")
        mnemonic = Elixium.Mnemonic.from_entropy(private)
        File.write!(unix_address <> "/#{pub}_backup.txt", mnemonic)
        :ok
      else
        :error
      end
    end

  end
