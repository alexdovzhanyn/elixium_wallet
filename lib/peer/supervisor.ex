defmodule ElixiumWallet.PeerRouter.Supervisor do
  use Supervisor
  require Logger

  def start_link(_args) do
    Logger.info("PEER ROUTER SUPERVISOR RUNNING")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      ElixiumWallet.PeerRouter
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
