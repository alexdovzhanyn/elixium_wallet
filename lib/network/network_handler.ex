defmodule ElixWallet.NetworkHandler do
    use GenServer
    require Logger
    alias ElixWallet.NetworkHelpers

    def start_link(args) do
      GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def reset_timer() do
      GenServer.call(__MODULE__, :reset_timer)
    end

    def init(state) do
      Logger.info("Network Handler Listening")
      timer = Process.send_after(self(), :work, 25_000)
      {:ok, %{timer: timer}}
    end

    def handle_call(:reset_timer, _from, %{timer: timer}) do
      :timer.cancel(timer)
      timer = Process.send_after(self(), :work, 1_000)
      {:reply, :ok, %{timer: timer}}
    end

    def handle_info(:work, state) do
      NetworkHelpers.get_stats()

      timer = Process.send_after(self(), :work, 60_000)
      {:noreply, %{timer: timer}}
    end

    # So that unhanded messages don't error
    def handle_info(_, state) do
      {:ok, state}
    end


end
