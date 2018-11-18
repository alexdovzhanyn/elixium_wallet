# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configure the main viewport for the Scenic application
config :elix_wallet, :viewport, %{
  name: :main_viewport,
  size: {1024, 640},
  default_scene: {ElixWallet.Scene.Send, ElixWallet.Scene.Home},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "elix_wallet"]
    }
  ]
}

config :elix_wallet,
port: 31012

config :elix_wallet, :theme, %{
  width: 800,
  height: 600,
  nav: {121, 101, 179},
  darknav: {86, 79, 162},
  black: {27, 27, 27},
  jade: {66, 193, 200},
  shadow: {35, 35, 35},
  notes: {35, 35, 35}
}

config :elix_wallet, :settings, %{
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




# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
