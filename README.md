# Elixium GUI Wallet
Official GUI Wallet implementation for the Elixium blockchain


### Features & News
1. Ability to Send & Receive XEX
2. Dynamic Mining Fee per Transaction
3. Create, Backup & Manage Your Keys
4. QR Codes for easy Transaction information
5. Elixium Network Statistics


Website:
https://www.elixiumnetwork.org/

Telegram:
https://t.me/elixiumnetwork

### How to Run

Grab the appropriate [latest release](https://github.com/ElixiumNetwork/elixium_wallet/releases/latest)
and unzip it. If you don't see a release fitting your system, you will
have to build from source.

The next step is to [port forward](https://www.pcworld.com/article/244314/how_to_forward_ports_on_your_router.html)
ports 31013, 31014, and 32123 on your router. If you don't do this, other
nodes on the network won't be able to connect to yours.

#### Advanced Usage

People who are comfortable working within a terminal may prefer to create their own
run script. To see usage options, cd into the directory where the miner is extracted,
and run `./bin/elixium_wallet foreground`.

### Building from Source

If none of the release candidates match your system architecture, it will be
necessary to build from source. It is important to have elixir installed on your
machine, this can be done by following the [installation instructions](https://elixir-lang.org/install.html).

In order to build from source:

1. Clone this repository
2. Run `mix deps.get`
3. Run `MIX_ENV=prod mix release`

Upon successful build, a tarball containing the compiled build can be found
in `_build/prod/rel/elixium_wallet/releases/<version_number>/elixium_wallet.tar.gz`
