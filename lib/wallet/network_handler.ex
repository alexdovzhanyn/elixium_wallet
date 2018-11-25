defmodule ElixWallet.Wallet.NetworkHandler do
    use GenServer
    require Logger

    def start_link(args) do
      GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def reset_timer() do
      GenServer.call(__MODULE__, :reset_timer)
    end

    def init(state) do
      Logger.info("Network Handler Listening")
      Process.send_after(self(), :setup, 20_000)
      timer = Process.send_after(self(), :work, 25_000)
      {:ok, %{timer: timer}}
    end

    def handle_call(:reset_timer, _from, %{timer: timer}) do
      :timer.cancel(timer)
      timer = Process.send_after(self(), :work, 1_000)
      {:reply, :ok, %{timer: timer}}
    end

    def handle_info(:work, state) do
      ElixWallet.Network.Helpers.get_stats()

      timer = Process.send_after(self(), :work, 6_000)
      {:noreply, %{timer: timer}}
    end

    def handle_info(:setup, state) do
      ElixWallet.Network.Helpers.setup()
      {:noreply, state}
    end

    # So that unhanded messages don't error
    def handle_info(_, state) do
      {:ok, state}
    end


end
