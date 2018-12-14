defmodule ElixiumWallet.Scene.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      {ElixiumWallet.Component.Notes, {"notes", [name: :notes]}}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
