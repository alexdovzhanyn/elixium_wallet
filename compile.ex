defmodule Mix.Tasks.Compile.MyNifs do
  def run(_args) do
    {result, _errcode} = System.cmd("make", [], stdout_to_stderr: true)
    IO.binwrite(result)
  end
end
