defmodule Lox do
  use Agent

  def init() do
    Agent.start_link(fn -> %{:hadError => false} end, name: __MODULE__)
  end

  # reads
  def hadError do
    Agent.get(__MODULE__, fn(state) -> state.hadError end)
  end

  # writes

  def clearError do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, :hadError, false) end)
  end


  TODO: This needs to dispatch on args.  It can get either line as a string, 
  in which case it needs to do the thing thats commented out
  or it can get a token, in which case it needs to do the rest of the body
  def error(line, message) do
    # report(line, "", message)
    if Token.get(token, :type) == :EOF do
      report(
        Token.get(token, :line),
        " at end",
        message
      )
    else
      report(
        Token.get(token, :line),
        " at '#{Token.get(token, :lexeme)}'",
        message
      )
    end
  end

  defp report(line, where, message) do
    IO.puts "[line #{line}] Error #{where}: #{message}"
    Agent.update(__MODULE__, fn(state) -> Map.put(state, :hadError, true) end)
  end
end
