defmodule ElixWallet.Wallet.NetworkHandler do
    use GenServer

    def start_link(args) do
      GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def reset_timer() do
      GenServer.call(__MODULE__, :reset_timer)
    end

    def init(state) do
      ElixWallet.Network.Helpers.setup()
      timer = Process.send_after(self(), :work, 60_000)
      {:ok, %{timer: timer}}
    end

    def handle_call(:reset_timer, _from, %{timer: timer}) do
      :timer.cancel(timer)
      timer = Process.send_after(self(), :work, 60_000)
      {:reply, :ok, %{timer: timer}}
    end

    def handle_info(:work, state) do
      # Do the work you desire here

      # Start the timer again
      ElixWallet.Network.Helpers.get_stats()

      timer = Process.send_after(self(), :work,6_000)

      {:noreply, %{timer: timer}}
    end

    # So that unhanded messages don't error
    def handle_info(_, state) do
      {:ok, state}
    end


end
