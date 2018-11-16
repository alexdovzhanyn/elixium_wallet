defmodule MessageHandler do
  use GenServer
  alias Elixium.P2P.Peer
  alias Elixium.Store.Ledger
  alias Elixium.Store.Utxo
  alias Elixium.Blockchain
  alias Elixium.P2P.Peer
  alias Elixium.Pool.Orphan
  alias Elixium.Validator
  alias Elixium.Blockchain.Block
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, self())
  end

  def init(parent_pid), do: {:ok, %{parent: parent_pid}}

  def handle_info(msg, state) do
    case msg do
      block = %{type: "BLOCK"} ->
        IO.inspect(block, limit: :infinity)
        # Check if we've already received a block at this index. If we have,
        # diff it against the one we've stored.
        case Ledger.block_at_height(block.index) do
          :none -> evaluate_new_block(block)
          stored_block -> handle_possible_fork(block, stored_block)
        end
      _ -> IO.puts "no match"
    end

    {:noreply, state}
  end

  @spec evaluate_new_block(Block) :: none
  defp evaluate_new_block(block) do
    last_block = Ledger.last_block()

    difficulty =
      if rem(block.index, Blockchain.diff_rebalance_offset()) == 0 do
        new_difficulty = Blockchain.recalculate_difficulty() + last_block.difficulty
        IO.puts("Difficulty recalculated! Changed from #{last_block.difficulty} to #{new_difficulty}")
        new_difficulty
      else
        last_block.difficulty
      end

    case Validator.is_block_valid?(block, difficulty) do
      :ok ->
        Logger.info("Block #{block.index} valid.")
        Blockchain.add_block(block)
        Peer.gossip("BLOCK", block)
      err -> Logger.info("Block #{block.index} invalid!")
    end
  end

  @spec handle_possible_fork(Block, Block) :: none
  defp handle_possible_fork(block, existing_block) do
    Logger.info("Already have block with index #{existing_block.index}. Performing block diff...")

    case Block.diff_header(existing_block, block) do
      # If there is no diff, just skip the block
      [] -> :no_diff
      diff ->
        Logger.warn("Fork block received! Checking existing orphan pool...")

        # Is this a fork of the most recent block? If it is, we don't have an orphan
        # chain to build on...
        if Ledger.last_block().index == block.index do
          # TODO: validate orphan block in context of its chain state before adding it
          Logger.warn("Received fork of current block")
          Orphan.add(block)
        else
          # Check the orphan pool for blocks at the previous height whose hash this
          # orphan block references as a previous_hash
          case Orphan.blocks_at_height(block.index - 1) do
            [] ->
              # We don't know of any ORPHAN blocks that this block might be referencing.
              # Perhaps this is a fork of a block that we've accepted as canonical into our
              # chain?
              case Ledger.retrieve_block(block.previous_hash) do
                :not_found ->
                  # If this block doesn't reference and blocks that we know of, we can not
                  # build a chain using this block -- we can't validate this block at all.
                  # Our only option is to drop the block. Realistically we shouldn't ever
                  # get into this situation unless a malicious actor has sent us a fake block.
                  Logger.warn("Received orphan block with no reference to a known block. Dropping orphan")
                canonical_block ->
                  # This block is a fork of a canonical block.
                  # TODO: Validate this fork in context of the chain state at this point in time
                  Logger.warn("Fork of canonical block received")
                  Orphan.add(block)
              end
            orphan_blocks ->
              # This block might be a fork of a block that we have stored in our
              # orphan pool
              Logger.warn("Possibly extension of existing fork")
          end
        end
    end
  end

end
