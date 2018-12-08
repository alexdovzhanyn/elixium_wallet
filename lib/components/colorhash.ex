defmodule ElixiumWallet.Component.ColorHash do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias ElixiumWallet.Utilities


  import Scenic.Primitives
  import Scenic.Components

  @height 30
  @font_size 20
  @indent 225
  @params {10,30}
  @theme Application.get_env(:elixium_wallet, :theme)

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------


    def init(notes, opts) do
      # Get the viewport width
      {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
        opts[:viewport]
        |> ViewPort.info()
        hash_list = Utilities.get_from_cache(:block_info, "last_blocks")
        colorhash = hash_list |> Enum.fetch!(0)
        colorhash1 = hash_list |> Enum.fetch!(1)
        colorhash2 = hash_list |> Enum.fetch!(2)
        colorhash3 = hash_list |> Enum.fetch!(3)
        colorhash4 = hash_list |> Enum.fetch!(4)
        [a,b,c,d,e,f,g,h,i,j,k] = hashstats(colorhash)
        [a1,b1,c1,d1,e1,f1,g1,h1,i1,j1,k1] = hashstats(colorhash1)
        [a2,b2,c2,d2,e2,f2,g2,h2,i2,j2,k2] = hashstats(colorhash2)
        [a3,b3,c3,d3,e3,f3,g3,h3,i3,j3,k3] = hashstats(colorhash3)
        [a4,b4,c4,d4,e4,f4,g4,h4,i4,j4,k4] = hashstats(colorhash4)

      graph =
        Graph.build(translate: {100, 0})
        |> rect(@params, fill: a, translate: {150, 350})
        |> rect(@params, fill: b, translate: {160, 350})
        |> rect(@params, fill: c, translate: {170, 350})
        |> rect(@params, fill: d, translate: {180, 350})
        |> rect(@params, fill: e, translate: {190, 350})
        |> rect(@params, fill: f, translate: {200, 350})
        |> rect(@params, fill: g, translate: {210, 350})
        |> rect(@params, fill: h, translate: {220, 350})
        |> rect(@params, fill: i, translate: {230, 350})
        |> rect(@params, fill: j, translate: {240, 350})
        |> rect(@params, fill: k, translate: {250, 350})
        |> rect(@params, fill: a1, translate: {270, 350})
        |> rect(@params, fill: b1, translate: {280, 350})
        |> rect(@params, fill: c1, translate: {290, 350})
        |> rect(@params, fill: d1, translate: {300, 350})
        |> rect(@params, fill: e1, translate: {310, 350})
        |> rect(@params, fill: f1, translate: {320, 350})
        |> rect(@params, fill: g1, translate: {330, 350})
        |> rect(@params, fill: h1, translate: {340, 350})
        |> rect(@params, fill: i1, translate: {350, 350})
        |> rect(@params, fill: j1, translate: {360, 350})
        |> rect(@params, fill: k1, translate: {370, 350})
        |> rect(@params, fill: a2, translate: {390, 350})
        |> rect(@params, fill: b2, translate: {400, 350})
        |> rect(@params, fill: c2, translate: {410, 350})
        |> rect(@params, fill: d2, translate: {420, 350})
        |> rect(@params, fill: e2, translate: {430, 350})
        |> rect(@params, fill: f2, translate: {440, 350})
        |> rect(@params, fill: g2, translate: {450, 350})
        |> rect(@params, fill: h2, translate: {460, 350})
        |> rect(@params, fill: i2, translate: {470, 350})
        |> rect(@params, fill: j2, translate: {480, 350})
        |> rect(@params, fill: k2, translate: {490, 350})
        |> rect(@params, fill: a3, translate: {510, 350})
        |> rect(@params, fill: b3, translate: {520, 350})
        |> rect(@params, fill: c3, translate: {530, 350})
        |> rect(@params, fill: d3, translate: {540, 350})
        |> rect(@params, fill: e3, translate: {550, 350})
        |> rect(@params, fill: f3, translate: {560, 350})
        |> rect(@params, fill: g3, translate: {570, 350})
        |> rect(@params, fill: h3, translate: {580, 350})
        |> rect(@params, fill: i3, translate: {590, 350})
        |> rect(@params, fill: j3, translate: {600, 350})
        |> rect(@params, fill: k3, translate: {610, 350})
        |> rect(@params, fill: a4, translate: {630, 350})
        |> rect(@params, fill: b4, translate: {640, 350})
        |> rect(@params, fill: c4, translate: {650, 350})
        |> rect(@params, fill: d4, translate: {660, 350})
        |> rect(@params, fill: e4, translate: {670, 350})
        |> rect(@params, fill: f4, translate: {680, 350})
        |> rect(@params, fill: g4, translate: {690, 350})
        |> rect(@params, fill: h4, translate: {700, 350})
        |> rect(@params, fill: i4, translate: {710, 350})
        |> rect(@params, fill: j4, translate: {720, 350})
        |> rect(@params, fill: k4, translate: {730, 350})
        |> push_graph()

      {:ok, %{graph: graph, viewport: opts[:viewport]}}
    end



      def hashstats(string) do
        string_chunks = String.codepoints(string) |> Enum.chunk_every(2)
        rgb_map = string_chunks |> Enum.map(fn chunks ->
          Enum.reduce(chunks, 0, fn codepoint, acc ->
            <<aacute::utf8>> = codepoint
            aacute + acc
          end)
        end)

        full_rgb_map = [0 | rgb_map]
        full_rgb_map |> Enum.chunk_every(3) |> Enum.map(fn list -> List.to_tuple(list) end)
      end

      def hash(string) do
        seed_0 = 131
        seed_1 = 137
        hash = 0
        max_safe_integer = 9007199254740991 / seed_1
        string_map = String.codepoints(string)
        hash = string_map |> Enum.map(fn codepoint ->
        if hash > max_safe_integer do
          hash = hash / seed_1
        end
          hash = hash * seed_0 + codepoint
        end)
      end




end
