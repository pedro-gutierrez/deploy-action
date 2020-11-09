defmodule Shell do
  def run(title, cmds) when is_list(cmds) do
    IO.puts(title)
    Enum.each(cmds, &run(&1))
  end

  def run(cmd) do
    {output, status} = System.cmd("sh", ["-c", cmd])

    if status != 0 do
      IO.inspect(cmd: cmd, rc: status, output: output)
      System.halt(status)
    end

    output
    |> String.trim()
    |> IO.inspect()
  end
end
