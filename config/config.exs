# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configure the main viewport for the Scenic application
config :elix_wallet, :viewport, %{
  name: :main_viewport,
  size: {800, 600},
  default_scene: {ElixWallet.Scene.Recieve, ElixWallet.Scene.Home},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "elix_wallet"]
    }
  ]
}



config :elix_wallet, :theme, %{
  nav: {75, 5, 109},
  shadow: {15, 15, 15},
  notes: {15,15,15}
}

config :elix_wallet, :settings, %{
  unix_key_location: Path.expand("../../.keys"),
  win32_key_location: Path.expand("../../.keys")
}





# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
