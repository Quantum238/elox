defmodule Elox do
  alias Scanner
  alias Lox
  @moduledoc """
  Documentation for Elox.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elox.hello()
      :world

  """
  def main(args) do
    options = [switches: [file: :string], aliases: [f: :file]]
    {opts, _, _} = OptionParser.parse(args, options)
    IO.inspect opts, label: "Command Line Arguments"
    IO.puts length(opts)

    cond do
      length(opts) > 1 ->
        IO.puts "Usage: elox [script]"
        System.halt(64)
      length(opts) == 1 ->
        Lox.init()
        runFile(opts[:file])
      true ->
        Lox.init()
        runPrompt()
    end
  end


  defp run(source) do
    if Lox.hadError do
      System.halt(65)
    end
    Scanner.init(source)
    tokens = Scanner.scanTokens()
    IO.inspect(tokens)
    for token <- tokens, do: IO.puts Token.toString(token)
  end

  defp runFile(path) do
    IO.puts "Running File #{path}"
    _file = File.open!(path, [:read, :utf8])
    contents = File.read!(path)
    IO.puts "File says #{contents}"
    File.close(path)
    run(contents)
  end

  defp runPrompt do
    IO.puts "Running Interactively"
    input = IO.gets "> "
    run(input)
    Lox.clearError()
    runPrompt()
  end

  
end
