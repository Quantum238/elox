defmodule Lox do
  use Agent

  def init() do
    Agent.start_link(fn -> %{hadError: false, hadRuntimeError: false} end, name: __MODULE__)
  end

  # reads
  def hadError do
    Agent.get(__MODULE__, fn(state) -> state.hadError end)
  end

  def hadRuntimeError do
    Agent.get(__MODULE__, fn(state) -> state.hadRuntimeError end)
  end

  # writes

  def clearError do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, :hadError, false) end)
  end

  def runtimeError(runtime_error) do
      IO.puts "#{runtime_error.message} \n [line #{Token.get(runtime_error.token, :line)}]"
      Agent.update(__MODULE__, fn(state) -> Map.put(state, :hadRuntimeError, true) end)
  end


  def error(line, message) when is_binary(line) do
    report(line, "", message)
  end
  def error(token, message) do
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
