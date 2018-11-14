defmodule ElixWallet.MixProject do
  use Mix.Project

  def project do
    [
      app: :elix_wallet,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixWallet, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:local_dependency, path: "../elixium_core", app: false},
      {:scenic, git: "https://github.com/boydm/scenic.git", override: true},
       {:eqrcode, "~> 0.1.5"},
      {:scenic_driver_glfw, "~> 0.9"},
    ]
  end
end
