defmodule ElixWallet.Settings do

# Sets the correct Loaction Based on OS
defp get_location({:unix, os}) do
Path.expand("../../.keys")
end
defp get_location({:win32, os}) do
IO.puts "Tes1t"
end

end
