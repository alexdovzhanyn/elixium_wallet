# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configure the main viewport for the Scenic application
config :elixium_wallet, :viewport, %{
  name: :main_viewport,
  size: {1024, 640},
  default_scene: {ElixiumWallet.Scene.Splash, ElixiumWallet.Scene.Home},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "elixium_wallet"]
    }
  ]
}

config :elixium_wallet,
port: 31012

config :elixium_wallet, :theme, %{
  width: 800,
  height: 600,
  nav: {121, 101, 179},
  darknav: {86, 79, 162},
  black: {27, 27, 27},
  jade: {66, 193, 200},
  shadow: {35, 35, 35},
  notes: {35, 35, 35}
}

config :elixium_wallet, :settings, %{
  unix_key_location: Path.expand("../../.keys"),
  win32_key_location: Path.expand("../../.keys")
}

config :clipboard,
  unix: [
    copy: {"xclip", ["-sel"]},
    paste: {"xclip", ["-o"]},
  ],
  macosx: [
    copy: {"xclip", ["-i"]},
    paste: {"xclip", ["-o"]},
  ]

config :elixium_wallet,
seed_peers: [
  "206.189.103.38:31013",
  "142.93.158.121:31013",
  "142.93.152.227:31013",
  "139.59.13.96:31013"
]




# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
