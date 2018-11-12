defmodule ElixWallet.QRCode do
  alias ElixWallet.Encode
  alias ElixWallet.ReedSolomon
  alias ElixWallet.Matrix
  alias ElixWallet.Mask
  alias ElixWallet.GaloisField
  alias ElixWallet.Render
  @moduledoc """
  QR Code implementation in Elixir.

  Spec:
    - Version: 1 - 7
    - ECC level: L
    - Encoding mode: Byte

  References:
    - ISO/IEC 18004:2006(E)
    - http://www.thonky.com/qr-code-tutorial/
  """

  @doc """
  Encode the binary.
  """
  @spec encode(binary) :: ElixWallet.Matrix.t
  def encode(bin) when byte_size(bin) <= 154 do
    data = ElixWallet.Encode.encode(bin)
      |> ElixWallet.ReedSolomon.encode()

    ElixWallet.Encode.version(bin)
    |> ElixWallet.Matrix.new()
    |> ElixWallet.Matrix.draw_finder_patterns()
    |> ElixWallet.Matrix.draw_seperators()
    |> ElixWallet.Matrix.draw_alignment_patterns()
    |> ElixWallet.Matrix.draw_timing_patterns()
    |> ElixWallet.Matrix.draw_dark_module()
    |> ElixWallet.Matrix.draw_reserved_format_areas()
    |> ElixWallet.Matrix.draw_reserved_version_areas()
    |> ElixWallet.Matrix.draw_data_with_mask(data)
    |> ElixWallet.Matrix.draw_format_areas()
    |> ElixWallet.Matrix.draw_version_areas()
    |> ElixWallet.Matrix.draw_quite_zone()
  end
  def encode(_), do: IO.puts "Binary too long."

  @doc """
  Encode the binary with custom pattern bits. Only supports version 5.
  """
  @spec encode(binary, bitstring) :: ElixWallet.Matrix.t
  def encode(bin, bits) when byte_size(bin) <= 106 do
    data = ElixWallet.Encode.encode(bin, bits)
      |> ElixWallet.ReedSolomon.encode()

    ElixWallet.Matrix.new(5)
    |> ElixWallet.Matrix.draw_finder_patterns()
    |> ElixWallet.Matrix.draw_seperators()
    |> ElixWallet.Matrix.draw_alignment_patterns()
    |> ElixWallet.Matrix.draw_timing_patterns()
    |> ElixWallet.Matrix.draw_dark_module()
    |> ElixWallet.Matrix.draw_reserved_format_areas()
    |> ElixWallet.Matrix.draw_data_with_mask0(data)
    |> ElixWallet.Matrix.draw_format_areas()
    |> ElixWallet.Matrix.draw_quite_zone()
  end
  def encode(_, _), do: IO.puts "Binary too long."

  defdelegate render(matrix),  to: ElixWallet.Render
  defdelegate render2(matrix), to: ElixWallet.Render
end
