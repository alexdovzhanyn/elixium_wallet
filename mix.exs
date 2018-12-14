defmodule ElixiumWallet.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixium_wallet,
      version: "0.1.4",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixiumWallet, []},
      extra_applications: [
        :elixium_core,
        :ssl,
        :logger,
        :inets,
        :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [ {:elixium_core, "~> 0.6"},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.4"},
      {:scenic, git: "https://github.com/fantypants/scenic.git", override: true},
      {:eqrcode, "~> 0.1.5"},
      {:clipboard, ">= 0.0.0"},
      {:scenic_driver_glfw, "~> 0.9"},
    ]
  end
end
